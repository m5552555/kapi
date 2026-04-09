// preset.dart
// Purpose: Immutable full-snapshot model for a named saved API request definition.

import 'api_request.dart';
import 'auth_config.dart';
import 'endpoint_type.dart';
import 'kv_pair.dart';

/// Immutable model representing a complete saved API request snapshot.
/// Every field of the request form is captured so that loading a preset
/// restores an exact replica of the saved state — not a partial overlay.
class Preset {
  /// Bump when the JSON schema changes in a breaking way.
  /// Version 1: legacy partial preset (baseUrl + auth + headers only, no version field).
  /// Version 2: full request snapshot including method, endpoint, body, params, endpoint type.
  static const int _schemaVersion = 2;

  const Preset({
    required this.id,
    required this.name,
    required this.createdAt,
    this.baseUrl = '',
    this.endpoint = '',
    this.method = HttpMethod.get,
    this.endpointType = EndpointType.normal,
    this.authType = AuthType.none,
    this.apiKeyPlacement = ApiKeyPlacement.header,
    this.username = '',
    this.password = '',
    this.token = '',
    this.apiKeyName = '',
    this.apiKeyValue = '',
    this.headers = const [],
    this.queryParams = const [],
    this.pathParams = const [],
    this.formFields = const [],
    this.bodyType = BodyType.none,
    this.rawJsonBody = '',
  });

  final String id;
  final String name;
  final DateTime createdAt;

  // ── Request identity ────────────────────────────────────────────────────────
  final String baseUrl;
  final String endpoint;
  final HttpMethod method;
  final EndpointType endpointType;

  // ── Authentication ──────────────────────────────────────────────────────────
  final AuthType authType;
  final ApiKeyPlacement apiKeyPlacement;
  final String username;
  final String password;
  final String token;
  final String apiKeyName;
  final String apiKeyValue;

  // ── Key-value sections ──────────────────────────────────────────────────────
  final List<KVPair> headers;
  final List<KVPair> queryParams;
  final List<KVPair> pathParams;
  final List<KVPair> formFields;

  // ── Body ────────────────────────────────────────────────────────────────────
  final BodyType bodyType;
  final String rawJsonBody;

  // ── Serialization ───────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'version': _schemaVersion,
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'baseUrl': baseUrl,
        'endpoint': endpoint,
        'method': method.name,
        'endpointType': endpointType.name,
        'authType': authType.name,
        'apiKeyPlacement': apiKeyPlacement.name,
        'username': username,
        'password': password,
        'token': token,
        'apiKeyName': apiKeyName,
        'apiKeyValue': apiKeyValue,
        'headers': _kvPairsToJson(headers),
        'queryParams': _kvPairsToJson(queryParams),
        'pathParams': _kvPairsToJson(pathParams),
        'formFields': _kvPairsToJson(formFields),
        'bodyType': bodyType.name,
        'rawJsonBody': rawJsonBody,
      };

  /// Deserializes a preset from JSON.
  /// Returns null only when the version field is explicitly newer than [_schemaVersion].
  /// All fields missing from older saves fall back to safe defaults so that
  /// version-1 presets (no version field) are still loadable.
  static Preset? fromJson(Map<String, dynamic> json) {
    try {
      final version = json['version'] as int?;
      // A missing version field indicates a v1 legacy preset — still readable.
      // An explicitly higher version means a format we cannot understand; skip it.
      if (version != null && version > _schemaVersion) return null;

      return Preset(
        id: (json['id'] as String?) ?? '',
        name: (json['name'] as String?) ?? 'Unnamed',
        createdAt:
            DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
                DateTime.now(),
        baseUrl: (json['baseUrl'] as String?) ?? '',
        endpoint: (json['endpoint'] as String?) ?? '',
        method: _enumByName(
          HttpMethod.values, json['method'] as String?, HttpMethod.get),
        endpointType: _enumByName(
          EndpointType.values, json['endpointType'] as String?, EndpointType.normal),
        authType: _enumByName(
          AuthType.values, json['authType'] as String?, AuthType.none),
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
        headers: _kvPairsFromJson(json['headers']),
        queryParams: _kvPairsFromJson(json['queryParams']),
        pathParams: _kvPairsFromJson(json['pathParams']),
        formFields: _kvPairsFromJson(json['formFields']),
        bodyType: _enumByName(
          BodyType.values, json['bodyType'] as String?, BodyType.none),
        rawJsonBody: (json['rawJsonBody'] as String?) ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _kvPairsToJson(List<KVPair> pairs) =>
      pairs
          .map((p) => {'key': p.key, 'value': p.value, 'enabled': p.enabled})
          .toList();

  static List<KVPair> _kvPairsFromJson(dynamic raw) {
    if (raw is! List) return [];
    return raw.whereType<Map<String, dynamic>>().map((e) {
      return KVPair(
        key: (e['key'] as String?) ?? '',
        value: (e['value'] as String?) ?? '',
        enabled: (e['enabled'] as bool?) ?? true,
      );
    }).toList();
  }

  static T _enumByName<T extends Enum>(
      List<T> values, String? name, T fallback) {
    if (name == null) return fallback;
    return values.where((e) => e.name == name).firstOrNull ?? fallback;
  }
}