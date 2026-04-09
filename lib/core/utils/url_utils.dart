// url_utils.dart
// Purpose: URL composition, normalization, path-parameter substitution, and URI building.

import '../../features/api_tester/domain/models/auth_config.dart';
import '../../features/api_tester/domain/models/kv_pair.dart';

abstract final class UrlUtils {
  /// Joins baseUrl and endpoint, handling extra slashes correctly.
  static String compose(String baseUrl, String endpoint) {
    baseUrl = baseUrl.trim();
    endpoint = endpoint.trim();

    if (endpoint.isEmpty) return baseUrl;
    if (baseUrl.isEmpty) return endpoint;

    while (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    if (!endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }

    return '$baseUrl$endpoint';
  }

  /// Substitutes {placeholder} tokens in the path with values from pathParams.
  static String substitutePaths(String url, List<KVPair> pathParams) {
    var result = url;
    for (final param in pathParams) {
      if (param.key.isEmpty || !param.enabled) continue;
      result = result.replaceAll('{${param.key}}', param.value);
    }
    return result;
  }

  /// Builds a Uri from a composed URL, merging query params and API-key-in-query auth.
  static Uri buildUri(
    String url,
    List<KVPair> queryParams,
    AuthConfig auth,
  ) {
    final base = Uri.parse(url);
    final Map<String, String> qp = Map.of(base.queryParameters);

    for (final p in queryParams) {
      if (p.enabled && p.key.isNotEmpty) {
        qp[p.key] = p.value;
      }
    }

    if (auth.type == AuthType.apiKey &&
        auth.apiKeyPlacement == ApiKeyPlacement.query &&
        auth.apiKeyName.isNotEmpty) {
      qp[auth.apiKeyName] = auth.apiKeyValue;
    }

    return base.replace(queryParameters: qp.isEmpty ? null : qp);
  }

  /// Returns a display-friendly composed URL for the user.
  static String displayUrl(String baseUrl, String endpoint) {
    return compose(baseUrl, endpoint);
  }

  /// Validates that a string is a parseable HTTP/HTTPS URL.
  static String? validateBaseUrl(String value) {
    if (value.trim().isEmpty) return 'Base URL is required.';
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme) return 'Base URL must include a scheme (http:// or https://).';
    if (!uri.scheme.startsWith('http')) return 'Base URL must use http or https.';
    if (uri.host.isEmpty) return 'Base URL is missing a host.';
    return null;
  }

  /// Extracts all {placeholder} names from an endpoint string.
  static List<String> extractPathPlaceholders(String endpoint) {
    final pattern = RegExp(r'\{([^}]+)\}');
    return pattern.allMatches(endpoint).map((m) => m.group(1)!).toList();
  }
}
