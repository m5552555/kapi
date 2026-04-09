// request_executor.dart
// Purpose: Sends HTTP requests and maps transport and server failures into structured app results.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/utils/url_utils.dart';
import '../domain/models/api_request.dart';
import '../domain/models/api_response.dart';
import '../domain/models/auth_config.dart';
import '../domain/models/kv_pair.dart';
import 'error_interpreter.dart';
import 'response_parser.dart';

abstract final class RequestExecutor {
  static const Duration _timeout = Duration(seconds: 30);

  /// Executes the given [ApiRequest] and returns an [ApiResponse].
  /// Throws an [AppError] on network/transport failure.
  ///
  /// Header application order (matches [RequestTraceBuilder] exactly):
  ///   1. Auth headers (Authorization or custom API key header)
  ///   2. Body Content-Type (determined by body type, cannot be overridden)
  ///   3. Custom user headers (Content-Type stripped when body type is active)
  static Future<ApiResponse> execute(ApiRequest request) async {
    final composed = UrlUtils.compose(request.baseUrl, request.endpoint);
    final pathResolved = UrlUtils.substitutePaths(composed, request.activePathParams);
    final uri = UrlUtils.buildUri(pathResolved, request.activeQueryParams, request.auth);

    final httpRequest = http.Request(request.method.label, uri);

    _applyAuth(httpRequest, request.auth);
    _applyBody(httpRequest, request);
    _applyCustomHeaders(httpRequest, request.activeHeaders, request.bodyType);

    final client = http.Client();
    final stopwatch = Stopwatch()..start();

    try {
      final streamed = await client.send(httpRequest).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      stopwatch.stop();
      return ResponseParser.parse(response, stopwatch.elapsed, uri.toString());
    } on TimeoutException catch (e) {
      throw ErrorInterpreter.fromException(e);
    } on SocketException catch (e) {
      throw ErrorInterpreter.fromException(e);
    } on HandshakeException catch (e) {
      throw ErrorInterpreter.fromException(e);
    } on HttpException catch (e) {
      throw ErrorInterpreter.fromException(e);
    } catch (e) {
      throw ErrorInterpreter.fromException(e);
    } finally {
      stopwatch.stop();
      client.close();
    }
  }

  static void _applyAuth(http.Request request, AuthConfig auth) {
    switch (auth.type) {
      case AuthType.none:
        break;
      case AuthType.basicAuth:
        final credentials = base64Encode(
          utf8.encode('${auth.username}:${auth.password}'),
        );
        request.headers['Authorization'] = 'Basic $credentials';
      case AuthType.bearerToken:
        request.headers['Authorization'] = 'Bearer ${auth.token}';
      case AuthType.apiKey:
        final name = auth.apiKeyName.trim();
        if (auth.apiKeyPlacement == ApiKeyPlacement.header && name.isNotEmpty) {
          request.headers[name] = auth.apiKeyValue.trim();
        }
        // Query placement is handled in UrlUtils.buildUri
    }
  }

  /// Applies body content and its Content-Type header.
  ///
  /// Form fields are encoded manually via Uri.encodeQueryComponent rather than
  /// using [http.Request.bodyFields], because that setter throws a [StateError]
  /// if Content-Type is already set to anything other than
  /// application/x-www-form-urlencoded. By encoding manually and setting
  /// [http.Request.body] directly we avoid that constraint entirely.
  static void _applyBody(http.Request request, ApiRequest apiRequest) {
    switch (apiRequest.bodyType) {
      case BodyType.none:
        break;
      case BodyType.rawJson:
        final body = apiRequest.rawJsonBody.trim();
        if (body.isNotEmpty) {
          request.body = body;
          request.headers['Content-Type'] = 'application/json; charset=utf-8';
        }
      case BodyType.formUrlEncoded:
      case BodyType.formData:
        final encoded = apiRequest.activeFormFields
            .map((f) =>
                '${Uri.encodeQueryComponent(f.key)}=${Uri.encodeQueryComponent(f.value)}')
            .join('&');
        request.body = encoded;
        request.headers['Content-Type'] =
            'application/x-www-form-urlencoded; charset=utf-8';
    }
  }

  /// Applies trimmed custom user headers after auth and body headers are set.
  /// Skips any Content-Type header when [bodyType] is not [BodyType.none],
  /// ensuring the correct wire-format Content-Type always wins.
  static void _applyCustomHeaders(
    http.Request request,
    List<KVPair> headers,
    BodyType bodyType,
  ) {
    for (final header in headers) {
      final key = header.key.trim();
      if (key.isEmpty) continue;
      if (bodyType != BodyType.none && key.toLowerCase() == 'content-type') continue;
      request.headers[key] = header.value.trim();
    }
  }
}
