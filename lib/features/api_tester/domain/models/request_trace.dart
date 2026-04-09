// request_trace.dart
// Purpose: Immutable snapshot of the exact request parameters sent on the wire, used for diagnostics and report export.

/// Captures what was actually sent (or would be sent) on the wire for a given API request.
/// Built by [RequestTraceBuilder] before sending and stored in [ApiTesterNotifier.lastTrace].
class RequestTrace {
  const RequestTrace({
    required this.fullUrl,
    required this.method,
    required this.sentHeaders,
    required this.bodyType,
    required this.bodyText,
    required this.curlCommand,
  });

  /// Fully composed URL including path substitutions and query parameters.
  final String fullUrl;

  /// HTTP method in uppercase (e.g. "POST", "GET").
  final String method;

  /// Final deduplicated, trimmed headers actually sent.
  /// Content-Type is always the body-type value when a body is present.
  final Map<String, String> sentHeaders;

  /// Human-readable body type label (e.g. "Form URL Encoded").
  final String bodyType;

  /// Actual encoded request payload as it appears on the wire.
  /// Empty string when body type is None.
  final String bodyText;

  /// Ready-to-run cURL (curl.exe) command that reproduces this exact request.
  final String curlCommand;
}
