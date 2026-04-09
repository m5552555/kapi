// endpoint_type.dart
// Purpose: Enum classifying the purpose of the current request for the guided token-based API testing workflow.

/// Classifies what the current request is used for, enabling Kapi's guided token flow.
///
/// - [normal]: standard API call with no automatic token handling.
/// - [tokenEndpoint]: Kapi extracts and stores the token from the response.
/// - [protectedEndpoint]: Kapi automatically injects the stored token as Authorization.
enum EndpointType {
  normal,
  tokenEndpoint,
  protectedEndpoint;

  /// Short label shown in the type selector chips.
  String get label => switch (this) {
        EndpointType.normal => 'Normal',
        EndpointType.tokenEndpoint => 'Token Endpoint',
        EndpointType.protectedEndpoint => 'Protected Endpoint',
      };

  /// Beginner-friendly one-liner shown below the type selector.
  String get hint => switch (this) {
        EndpointType.normal =>
          'Regular API request — no special token handling.',
        EndpointType.tokenEndpoint =>
          'This request gets your login token. Kapi saves it automatically.',
        EndpointType.protectedEndpoint =>
          'This request uses the saved token automatically.',
      };
}
