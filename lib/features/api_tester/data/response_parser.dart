// response_parser.dart
// Purpose: Converts a raw http.Response into a structured ApiResponse, handling JSON formatting and size tracking.

import 'package:http/http.dart' as http;

import '../../../core/utils/json_utils.dart';
import '../domain/models/api_response.dart';

abstract final class ResponseParser {
  static ApiResponse parse(
    http.Response raw,
    Duration duration,
    String fullUrl,
  ) {
    final rawBody = raw.body;
    final sizeBytes = raw.bodyBytes.length;
    final contentType = raw.headers['content-type'];
    final isJson = JsonUtils.isJsonContentType(contentType) ||
        (contentType == null && JsonUtils.looksLikeJson(rawBody));

    final String body;
    if (isJson && rawBody.isNotEmpty) {
      body = JsonUtils.formatOrRaw(rawBody);
    } else {
      body = rawBody;
    }

    // Normalize headers: http package gives lowercase keys already.
    final headers = Map<String, String>.from(raw.headers);

    return ApiResponse(
      statusCode: raw.statusCode,
      statusMessage: _statusMessage(raw.statusCode),
      duration: duration,
      sizeBytes: sizeBytes,
      headers: headers,
      body: body,
      rawBody: rawBody,
      timestamp: DateTime.now(),
      fullUrl: fullUrl,
      isJson: isJson,
      connectionEstablished: true,
    );
  }

  static String _statusMessage(int code) => switch (code) {
        100 => 'Continue',
        101 => 'Switching Protocols',
        200 => 'OK',
        201 => 'Created',
        202 => 'Accepted',
        204 => 'No Content',
        206 => 'Partial Content',
        301 => 'Moved Permanently',
        302 => 'Found',
        304 => 'Not Modified',
        307 => 'Temporary Redirect',
        308 => 'Permanent Redirect',
        400 => 'Bad Request',
        401 => 'Unauthorized',
        403 => 'Forbidden',
        404 => 'Not Found',
        405 => 'Method Not Allowed',
        408 => 'Request Timeout',
        409 => 'Conflict',
        410 => 'Gone',
        413 => 'Content Too Large',
        415 => 'Unsupported Media Type',
        422 => 'Unprocessable Entity',
        429 => 'Too Many Requests',
        500 => 'Internal Server Error',
        501 => 'Not Implemented',
        502 => 'Bad Gateway',
        503 => 'Service Unavailable',
        504 => 'Gateway Timeout',
        _ => 'Unknown Status',
      };
}
