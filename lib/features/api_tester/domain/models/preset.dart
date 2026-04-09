// preset.dart
// Purpose: Immutable model for a named user-defined request configuration preset (base URL, auth, headers).

import 'auth_config.dart';
import 'kv_pair.dart';

class Preset {
  const Preset({
    required this.id,
    required this.name,
    required this.createdAt,
    this.baseUrl = '',
    this.authType = AuthType.none,
    this.apiKeyPlacement = ApiKeyPlacement.header,
    this.username = '',
    this.password = '',
    this.token = '',
    this.apiKeyName = '',
    this.apiKeyValue = '',
    this.headers = const [],
  });

  final String id;
  final String name;
  final DateTime createdAt;

  // A preset stores the reusable "base config": URL + auth + common headers.
  // It intentionally excludes endpoint, query params, path params, and body
  // since those are request-specific and change per call.
  final String baseUrl;
  final AuthType authType;
  final ApiKeyPlacement apiKeyPlacement;
  final String username;
  final String password;
  final String token;
  final String apiKeyName;
  final String apiKeyValue;
  final List<KVPair> headers;

  // ─── Serialization ───────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'baseUrl': baseUrl,
        'authType': authType.name,
        'apiKeyPlacement': apiKeyPlacement.name,
        'username': username,
        'password': password,
        'token': token,
        'apiKeyName': apiKeyName,
        'apiKeyValue': apiKeyValue,
        'headers': headers
            .map((h) => {'key': h.key, 'value': h.value, 'enabled': h.enabled})
            .toList(),
      };

  static Preset? fromJson(Map<String, dynamic> json) {
    try {
      return Preset(
        id: (json['id'] as String?) ?? '',
        name: (json['name'] as String?) ?? 'Unnamed',
        createdAt:
            DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
                DateTime.now(),
        baseUrl: (json['baseUrl'] as String?) ?? '',
        authType:
            _enumByName(AuthType.values, json['authType'] as String?, AuthType.none),
        apiKeyPlacement: _enumByName(
          ApiKeyPlacement.values,
          json['apiKeyPlacement'] as String?,
          ApiKeyPlacement.header,
        ),
        username: (json['username'] as String?) ?? '',
        password: (json['password'] as String?) ?? '',
        token: (json['token'] as String?) ?? '',
        apiKeyName: (json['apiKeyName'] as String?) ?? '',
        apiKeyValue: (json['apiKeyValue'] as String?) ?? '',
        headers: _parseHeaders(json['headers']),
      );
    } catch (_) {
      return null;
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  static T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
    if (name == null) return fallback;
    return values.where((e) => e.name == name).firstOrNull ?? fallback;
  }

  static List<KVPair> _parseHeaders(dynamic raw) {
    if (raw is! List) return [];
    return raw.whereType<Map<String, dynamic>>().map((e) {
      return KVPair(
        key: (e['key'] as String?) ?? '',
        value: (e['value'] as String?) ?? '',
        enabled: (e['enabled'] as bool?) ?? true,
      );
    }).toList();
  }
}
