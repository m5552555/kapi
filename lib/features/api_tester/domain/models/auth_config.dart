// auth_config.dart
// Purpose: Auth type enum and immutable auth configuration model covering all supported auth strategies.

enum AuthType {
  none,
  basicAuth,
  bearerToken,
  apiKey;

  String get label => switch (this) {
        AuthType.none => 'None',
        AuthType.basicAuth => 'Basic Auth',
        AuthType.bearerToken => 'Bearer Token',
        AuthType.apiKey => 'API Key',
      };
}

enum ApiKeyPlacement {
  header,
  query;

  String get label => switch (this) {
        ApiKeyPlacement.header => 'Header',
        ApiKeyPlacement.query => 'Query Param',
      };
}

class AuthConfig {
  const AuthConfig({
    this.type = AuthType.none,
    this.username = '',
    this.password = '',
    this.token = '',
    this.apiKeyName = '',
    this.apiKeyValue = '',
    this.apiKeyPlacement = ApiKeyPlacement.header,
  });

  final AuthType type;
  final String username;
  final String password;
  final String token;
  final String apiKeyName;
  final String apiKeyValue;
  final ApiKeyPlacement apiKeyPlacement;

  /// Validates the auth fields for the selected type.
  String? validate() {
    switch (type) {
      case AuthType.none:
        return null;
      case AuthType.basicAuth:
        if (username.trim().isEmpty || password.trim().isEmpty) {
          return 'Basic authentication requires both username and password.';
        }
      case AuthType.bearerToken:
        if (token.trim().isEmpty) {
          return 'Bearer token authentication requires a token value.';
        }
      case AuthType.apiKey:
        if (apiKeyName.trim().isEmpty) {
          return 'API key authentication requires a key name.';
        }
        if (apiKeyValue.trim().isEmpty) {
          return 'API key authentication requires a key value.';
        }
    }
    return null;
  }
}
