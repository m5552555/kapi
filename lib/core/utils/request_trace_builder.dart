// request_trace_builder.dart
// Purpose: Computes the exact wire-level request (headers, body, URL, cURL) from an ApiRequest without sending it.

import 'dart:convert';

import '../../features/api_tester/domain/models/api_request.dart';
import '../../features/api_tester/domain/models/auth_config.dart';
import '../../features/api_tester/domain/models/kv_pair.dart';
import '../../features/api_tester/domain/models/request_trace.dart';
import 'url_utils.dart';

/// Mirrors [RequestExecutor]'s header/body logic exactly, without performing I/O.
/// Used in [ApiTesterNotifier.sendRequest] to capture diagnostic information
/// regardless of whether the request ultimately succeeds or fails.
abstract final class RequestTraceBuilder {
  /// Builds a [RequestTrace] from [request] by applying the same resolution
  /// rules as [RequestExecutor]: auth → body Content-Type → custom headers (filtered).
  static RequestTrace build(ApiRequest request) {
    final composed = UrlUtils.compose(request.baseUrl, request.endpoint);
    final pathResolved = UrlUtils.substitutePaths(composed, request.activePathParams);
    final uri = UrlUtils.buildUri(pathResolved, request.activeQueryParams, request.auth);

    final headers = <String, String>{};
    _applyAuth(headers, request.auth);
    _applyBodyContentType(headers, request);
    _applyCustomHeaders(headers, request.activeHeaders, request.bodyType);

    final bodyText = _computeBodyText(request);
    final curl = _buildCurl(uri.toString(), request.method.label, headers, bodyText);

    return RequestTrace(
      fullUrl: uri.toString(),
      method: request.method.label,
      sentHeaders: Map.unmodifiable(headers),
      bodyType: request.bodyType.label,
      bodyText: bodyText,
      curlCommand: curl,
    );
  }

  // ─── Header resolution ────────────────────────────────────────────────────────

  static void _applyAuth(Map<String, String> headers, AuthConfig auth) {
    switch (auth.type) {
      case AuthType.none:
        break;
      case AuthType.basicAuth:
        final creds = base64Encode(utf8.encode('${auth.username}:${auth.password}'));
        headers['Authorization'] = 'Basic $creds';
      case AuthType.bearerToken:
        headers['Authorization'] = 'Bearer ${auth.token}';
      case AuthType.apiKey:
        final name = auth.apiKeyName.trim();
        if (auth.apiKeyPlacement == ApiKeyPlacement.header && name.isNotEmpty) {
          headers[name] = auth.apiKeyValue.trim();
        }
    }
  }

  static void _applyBodyContentType(Map<String, String> headers, ApiRequest request) {
    switch (request.bodyType) {
      case BodyType.none:
        break;
      case BodyType.rawJson:
        if (request.rawJsonBody.trim().isNotEmpty) {
          headers['Content-Type'] = 'application/json; charset=utf-8';
        }
      case BodyType.formUrlEncoded:
      case BodyType.formData:
        headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=utf-8';
    }
  }

  /// Applies trimmed custom headers. Skips Content-Type when body type is active
  /// (the body's Content-Type always wins to preserve wire-format integrity).
  static void _applyCustomHeaders(
    Map<String, String> headers,
    List<KVPair> custom,
    BodyType bodyType,
  ) {
    for (final h in custom) {
      final key = h.key.trim();
      if (key.isEmpty) continue;
      if (bodyType != BodyType.none && key.toLowerCase() == 'content-type') continue;
      headers[key] = h.value.trim();
    }
  }

  // ─── Body encoding ────────────────────────────────────────────────────────────

  static String _computeBodyText(ApiRequest request) {
    return switch (request.bodyType) {
      BodyType.none => '',
      BodyType.rawJson => request.rawJsonBody.trim(),
      BodyType.formUrlEncoded || BodyType.formData => request.activeFormFields
          .map((f) =>
              '${Uri.encodeQueryComponent(f.key)}=${Uri.encodeQueryComponent(f.value)}')
          .join('&'),
    };
  }

  // ─── cURL generation ─────────────────────────────────────────────────────────

  static String _buildCurl(
    String url,
    String method,
    Map<String, String> headers,
    String body,
  ) {
    final buf = StringBuffer('curl.exe -X $method "$url"');
    for (final entry in headers.entries) {
      buf.write(' \\\n  -H "${entry.key}: ${entry.value}"');
    }
    if (body.isNotEmpty) {
      // Use single-quoted data to avoid shell interpolation on most terminals.
      final escaped = body.replaceAll("'", "'\\''");
      buf.write(" \\\n  --data '$escaped'");
    }
    return buf.toString();
  }
}
