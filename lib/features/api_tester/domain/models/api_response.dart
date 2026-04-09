// api_response.dart
// Purpose: Immutable model for a completed HTTP response including timing, headers, and parsed body.

class ApiResponse {
  const ApiResponse({
    required this.statusCode,
    required this.statusMessage,
    required this.duration,
    required this.sizeBytes,
    required this.headers,
    required this.body,
    required this.rawBody,
    required this.timestamp,
    required this.fullUrl,
    required this.isJson,
    required this.connectionEstablished,
  });

  final int statusCode;
  final String statusMessage;
  final Duration duration;
  final int sizeBytes;
  final Map<String, String> headers;

  /// Pretty-printed body if JSON; raw body otherwise.
  final String body;
  final String rawBody;
  final DateTime timestamp;
  final String fullUrl;
  final bool isJson;

  /// True if the server actually responded (even with 4xx/5xx).
  final bool connectionEstablished;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isRedirect => statusCode >= 300 && statusCode < 400;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;
  bool get isEmpty => rawBody.isEmpty;
}
