// token_extractor.dart
// Purpose: Parses common authentication token field names from a JSON API response body.

import 'dart:convert';

import '../domain/models/captured_token.dart';

/// Stateless utility that searches a JSON response for standard token fields.
///
/// Supports common naming conventions used by OAuth2, JWT, and proprietary APIs.
/// Searches the top level of the JSON object first, then one level of nesting.
abstract final class TokenExtractor {
  /// Token value field names in priority order.
  static const _tokenFields = [
    'access_token',
    'accessToken',
    'token',
    'jwt',
    'id_token',
    'idToken',
    'auth_token',
    'authToken',
    'bearer_token',
    'bearerToken',
  ];

  /// Token type field names.
  static const _typeFields = ['token_type', 'tokenType', 'type'];

  /// Token expiry field names (value expected in seconds).
  static const _expiresFields = ['expires_in', 'expiresIn', 'expires'];

  /// Attempts to extract a [CapturedToken] from [responseBody].
  ///
  /// Returns null when:
  /// - [responseBody] is not valid JSON
  /// - The root element is not a JSON object
  /// - None of the known token fields are found at the top level or one level deep
  static CapturedToken? extract(String responseBody, String sourceEndpoint) {
    try {
      final dynamic decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) return null;

      // Search top-level fields first, then one level of nesting
      final tokenValue = _findString(decoded, _tokenFields) ??
          _findNested(decoded, _tokenFields);
      if (tokenValue == null || tokenValue.isEmpty) return null;

      final rawType = _findString(decoded, _typeFields) ?? 'Bearer';
      final tokenType = _capitalize(rawType);
      final expiresIn = _findInt(decoded, _expiresFields);

      return CapturedToken(
        value: tokenValue,
        tokenType: tokenType,
        sourceEndpoint: sourceEndpoint,
        capturedAt: DateTime.now(),
        expiresIn: expiresIn,
      );
    } catch (_) {
      return null;
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  static String? _findString(Map<String, dynamic> map, List<String> fields) {
    for (final field in fields) {
      final v = map[field];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }

  static String? _findNested(Map<String, dynamic> map, List<String> fields) {
    for (final value in map.values) {
      if (value is Map<String, dynamic>) {
        final found = _findString(value, fields);
        if (found != null) return found;
      }
    }
    return null;
  }

  static int? _findInt(Map<String, dynamic> map, List<String> fields) {
    for (final field in fields) {
      final v = map[field];
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
    }
    return null;
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
