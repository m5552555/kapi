// captured_token.dart
// Purpose: Immutable model representing a successfully extracted auth token and its source metadata.

/// Holds the token value extracted from a Token Endpoint response, along with
/// contextual metadata needed for display, injection, and expiry checking.
class CapturedToken {
  const CapturedToken({
    required this.value,
    required this.tokenType,
    required this.sourceEndpoint,
    required this.capturedAt,
    this.expiresIn,
  });

  /// The raw token string (e.g. a JWT or opaque token).
  final String value;

  /// Token type prefix extracted from the response (e.g. "Bearer", "Token").
  /// Defaults to "Bearer" when the response does not include a token_type field.
  final String tokenType;

  /// The endpoint path that returned this token (used in status displays).
  final String sourceEndpoint;

  /// When the token was extracted from the response.
  final DateTime capturedAt;

  /// Lifetime in seconds from the server's expires_in field, if present.
  final int? expiresIn;

  // ─── Computed ────────────────────────────────────────────────────────────────

  /// Full Authorization header value ready to send: e.g. "Bearer eyJ…".
  String get authorizationValue => '$tokenType $value';

  /// Whether the token has likely expired based on capturedAt + expiresIn.
  /// Returns false when expiresIn is not known.
  bool get isLikelyExpired {
    if (expiresIn == null) return false;
    return DateTime.now().difference(capturedAt).inSeconds > expiresIn!;
  }

  /// Short masked display: first 10 characters + "…".
  /// Used in the UI so the token is not shown in full by default.
  String get maskedValue {
    if (value.length <= 10) return '•••';
    return '${value.substring(0, 10)}…';
  }
}
