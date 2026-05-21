part of 'package:kapi/features/api_tester/state/api_tester_notifier.dart';

// Purpose: Send mixin — request validation, auth config building, request building, and send/extract flow
// Keywords: send, validate, auth-config, request-build, token-extract, mixin

/// Send: validates the form, builds the HTTP request, executes it, and on a
/// successful Token Endpoint response extracts the bearer token for reuse.
mixin _SendMixin on _ApiTesterState {
  Future<void> sendRequest() async {
    _validationError = null;
    _tokenExtractionError = null;

    final validation = _validate();
    if (validation != null) {
      _validationError = validation;
      _requestState = ValidationErrorState(validation);
      notifyListeners();
      return;
    }

    // Record whether this specific send is a token endpoint request.
    _lastSendWasTokenEndpoint = _endpointType == EndpointType.tokenEndpoint;

    _requestState = const LoadingState();
    notifyListeners();

    final request = _buildRequest();
    _lastTrace = RequestTraceBuilder.build(request);

    try {
      final response = await RequestExecutor.execute(request);
      _requestState = SuccessState(response);
    } catch (e) {
      final error = ErrorInterpreter.fromException(e);
      _requestState = FailureState(error);
    }

    // Token extraction — only on successful Token Endpoint responses.
    if (_lastSendWasTokenEndpoint && _requestState is SuccessState) {
      final response = (_requestState as SuccessState).response;
      final extracted = TokenExtractor.extract(
        response.rawBody,
        endpointController.text.trim(),
      );
      if (extracted != null) {
        _capturedToken = extracted;
      } else {
        _tokenExtractionError =
            'No token field found in the response.\n'
            'The server must return one of: access_token, token, jwt, or id_token.';
      }
    }

    notifyListeners();
  }

  String? _validate() {
    final baseUrl = baseUrlController.text.trim();
    if (baseUrl.isEmpty) return 'Base URL is required.';

    final urlError = UrlUtils.validateBaseUrl(baseUrl);
    if (urlError != null) return urlError;

    // Protected endpoint requires a captured token (unless manual auth is configured).
    if (_endpointType == EndpointType.protectedEndpoint &&
        _capturedToken == null &&
        _authType == AuthType.none) {
      return 'No token available yet.\n'
          'Run a Token Endpoint request first to get your login token, '
          'then come back here.';
    }

    final authError = _buildAuthConfig().validate();
    if (authError != null) return authError;

    if (_bodyType == BodyType.rawJson) {
      final jsonError = JsonUtils.validateJson(rawJsonController.text);
      if (jsonError != null) return 'Raw JSON body is invalid: $jsonError';
    }

    final endpoint = endpointController.text;
    final placeholders = UrlUtils.extractPathPlaceholders(endpoint);
    for (final ph in placeholders) {
      final match = _pathParams.where((p) => p.key == ph).firstOrNull;
      if (match == null || match.value.trim().isEmpty) {
        return 'Path placeholder "{$ph}" has no value assigned.';
      }
    }

    return null;
  }

  /// Builds the [AuthConfig] for the current request.
  /// When the endpoint type is [EndpointType.protectedEndpoint] and a token has been
  /// captured and the user has not configured manual auth, the captured token is
  /// automatically used as a Bearer token. This is the core injection mechanism.
  AuthConfig _buildAuthConfig() {
    if (_endpointType == EndpointType.protectedEndpoint &&
        _capturedToken != null &&
        _authType == AuthType.none) {
      return AuthConfig(
        type: AuthType.bearerToken,
        token: _capturedToken!.value,
        username: '',
        password: '',
        apiKeyName: '',
        apiKeyValue: '',
        apiKeyPlacement: _apiKeyPlacement,
      );
    }
    return AuthConfig(
      type: _authType,
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
      token: tokenController.text.trim(),
      apiKeyName: apiKeyNameController.text.trim(),
      apiKeyValue: apiKeyValueController.text.trim(),
      apiKeyPlacement: _apiKeyPlacement,
    );
  }

  ApiRequest _buildRequest() {
    return ApiRequest(
      method: _method,
      baseUrl: baseUrlController.text.trim(),
      endpoint: endpointController.text.trim(),
      auth: _buildAuthConfig(),
      headers: List.of(_headers),
      queryParams: List.of(_queryParams),
      pathParams: List.of(_pathParams),
      bodyType: _bodyType,
      rawJsonBody: rawJsonController.text,
      formFields: List.of(_formFields),
    );
  }
}
