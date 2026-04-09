// api_request.dart
// Purpose: Enum and immutable model representing a fully-configured API request ready for execution.

import 'auth_config.dart';
import 'kv_pair.dart';

enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete,
  head,
  options;

  String get label => name.toUpperCase();

  bool get supportsBody => this == post || this == put || this == patch;
}

enum BodyType {
  none,
  rawJson,
  formUrlEncoded,
  formData;

  String get label => switch (this) {
        BodyType.none => 'None',
        BodyType.rawJson => 'JSON',
        BodyType.formUrlEncoded => 'Form URL Encoded',
        BodyType.formData => 'Form Data',
      };

  String? get contentType => switch (this) {
        BodyType.none => null,
        BodyType.rawJson => 'application/json',
        BodyType.formUrlEncoded => 'application/x-www-form-urlencoded',
        BodyType.formData => null, // set by http package for multipart
      };
}

class ApiRequest {
  const ApiRequest({
    required this.method,
    required this.baseUrl,
    required this.endpoint,
    required this.auth,
    required this.headers,
    required this.queryParams,
    required this.pathParams,
    required this.bodyType,
    required this.rawJsonBody,
    required this.formFields,
  });

  final HttpMethod method;
  final String baseUrl;
  final String endpoint;
  final AuthConfig auth;
  final List<KVPair> headers;
  final List<KVPair> queryParams;
  final List<KVPair> pathParams;
  final BodyType bodyType;
  final String rawJsonBody;
  final List<KVPair> formFields;

  /// Returns only enabled, non-empty headers.
  List<KVPair> get activeHeaders =>
      headers.where((h) => h.enabled && h.key.isNotEmpty).toList();

  /// Returns only enabled, non-empty query params.
  List<KVPair> get activeQueryParams =>
      queryParams.where((q) => q.enabled && q.key.isNotEmpty).toList();

  /// Returns only enabled, non-empty path params.
  List<KVPair> get activePathParams =>
      pathParams.where((p) => p.enabled && p.key.isNotEmpty).toList();

  /// Returns only enabled, non-empty form fields.
  List<KVPair> get activeFormFields =>
      formFields.where((f) => f.enabled && f.key.isNotEmpty).toList();
}
