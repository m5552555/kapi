// request_draft.dart
// Purpose: Serializable snapshot of the request form state used for last-draft persistence across sessions.

import 'kv_pair.dart';
import 'api_request.dart';
import 'auth_config.dart';
import 'endpoint_type.dart';

/// Serializable representation of the request builder form state.
/// Stored to disk and reloaded on the next app launch to restore the last draft.
/// Uses enum names as strings for forward compatibility and graceful degradation.
class RequestDraft {
  /// Bump this when the JSON schema changes in a breaking way.
  static const int _schemaVersion = 2;

  const RequestDraft({
    required this.baseUrl,
    required this.endpoint,
    required this.method,
    required this.authType,
    required this.apiKeyPlacement,
    required this.username,
    required this.password,
    required this.token,
    required this.apiKeyName,
    required this.apiKeyValue,
    required this.headers,
    required this.queryParams,
    required this.pathParams,
    required this.formFields,
    required this.bodyType,
    required this.rawJsonBody,
    required this.endpointType,
  });

  final String baseUrl;
  final String endpoint;
  final String method;          // HttpMethod.name
  final String authType;        // AuthType.name
  final String apiKeyPlacement; // ApiKeyPlacement.name
  final String username;
  final String password;
  final String token;
  final String apiKeyName;
  final String apiKeyValue;
  final List<KVPair> headers;
  final List<KVPair> queryParams;
  final List<KVPair> pathParams;
  final List<KVPair> formFields;
  final String bodyType;        // BodyType.name
  final String rawJsonBody;
  final String endpointType;   // EndpointType.name

  // ─── Serialization ───────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'version': _schemaVersion,
        'baseUrl': baseUrl,
        'endpoint': endpoint,
        'method': method,
        'authType': authType,
        'apiKeyPlacement': apiKeyPlacement,
        'username': username,
        'password': password,
        'token': token,
        'apiKeyName': apiKeyName,
        'apiKeyValue': apiKeyValue,
        'headers': _kvPairsToJson(headers),
        'queryParams': _kvPairsToJson(queryParams),
        'pathParams': _kvPairsToJson(pathParams),
        'formFields': _kvPairsToJson(formFields),
        'bodyType': bodyType,
        'rawJsonBody': rawJsonBody,
        'endpointType': endpointType,
      };

  /// Attempts to restore a draft from a JSON map.
  /// Returns null if the data is incompatible or fundamentally malformed.
  /// Individual missing or unknown fields fall back to safe defaults so that
  /// partial data from an older schema version is still usable.
  static RequestDraft? fromJson(Map<String, dynamic> json) {
    try {
      final version = json['version'] as int?;
      // If the schema version is unknown and in the future, skip restoration
      // to avoid applying a newer format we cannot understand.
      if (version != null && version > _schemaVersion) return null;

      return RequestDraft(
        baseUrl: (json['baseUrl'] as String?) ?? '',
        endpoint: (json['endpoint'] as String?) ?? '',
        method: _validEnumName(HttpMethod.values, json['method'] as String?) ?? HttpMethod.get.name,
        authType: _validEnumName(AuthType.values, json['authType'] as String?) ?? AuthType.none.name,
        apiKeyPlacement: _validEnumName(ApiKeyPlacement.values, json['apiKeyPlacement'] as String?) ?? ApiKeyPlacement.header.name,
        username: (json['username'] as String?) ?? '',
        password: (json['password'] as String?) ?? '',
        token: (json['token'] as String?) ?? '',
        apiKeyName: (json['apiKeyName'] as String?) ?? '',
        apiKeyValue: (json['apiKeyValue'] as String?) ?? '',
        headers: _kvPairsFromJson(json['headers']),
        queryParams: _kvPairsFromJson(json['queryParams']),
        pathParams: _kvPairsFromJson(json['pathParams']),
        formFields: _kvPairsFromJson(json['formFields']),
        bodyType: _validEnumName(BodyType.values, json['bodyType'] as String?) ?? BodyType.none.name,
        rawJsonBody: (json['rawJsonBody'] as String?) ?? '',
        endpointType: _validEnumName(EndpointType.values, json['endpointType'] as String?) ?? EndpointType.normal.name,
      );
    } catch (_) {
      // Any unexpected structure falls back to no restoration.
      return null;
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

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

  /// Returns the enum name string only if it matches a known enum value.
  /// Returns null for unknown names so the caller can supply a default.
  static String? _validEnumName(List<Enum> values, String? name) {
    if (name == null) return null;
    return values.any((e) => e.name == name) ? name : null;
  }
}
