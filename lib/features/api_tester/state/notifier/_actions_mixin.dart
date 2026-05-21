part of 'package:kapi/features/api_tester/state/api_tester_notifier.dart';

// Purpose: Actions mixin — full reset and preset-restore operations on the form state
// Keywords: actions, reset, preset, restore, snapshot, mixin

/// Actions: high-level user operations that fully replace the request form
/// state — `reset` clears everything, `loadFromPreset` restores an exact
/// snapshot.
mixin _ActionsMixin on _ApiTesterState {
  void reset() {
    _saveDebounce?.cancel();
    _saveDebounce = null;

    baseUrlController.clear();
    endpointController.clear();
    usernameController.clear();
    passwordController.clear();
    tokenController.clear();
    apiKeyNameController.clear();
    apiKeyValueController.clear();
    rawJsonController.clear();

    _method = HttpMethod.get;
    _authType = AuthType.none;
    _apiKeyPlacement = ApiKeyPlacement.header;
    _bodyType = BodyType.none;
    _endpointType = EndpointType.normal;

    _headers = [];
    _queryParams = [];
    _pathParams = [];
    _formFields = [];

    _requestState = const IdleState();
    _lastTrace = null;
    _capturedToken = null;
    _tokenExtractionError = null;
    _lastSendWasTokenEndpoint = false;
    _jsonError = null;
    _validationError = null;

    _resetKey++;

    DraftStorage.clear();
    notifyListeners();
  }

  /// Loads [preset] as an exact snapshot, fully replacing the current request form state.
  /// Performs a complete reset before applying the saved values so no stale state remains.
  /// The captured token (_capturedToken) is intentionally preserved — it is session-level
  /// runtime state and is not part of the saved request definition.
  void loadFromPreset(Preset preset) {
    _saveDebounce?.cancel();
    _saveDebounce = null;
    _isRestoring = true;

    // Populate all text controllers from the saved snapshot.
    baseUrlController.text = preset.baseUrl;
    endpointController.text = preset.endpoint;
    usernameController.text = preset.username;
    passwordController.text = preset.password;
    tokenController.text = preset.token;
    apiKeyNameController.text = preset.apiKeyName;
    apiKeyValueController.text = preset.apiKeyValue;
    rawJsonController.text = preset.rawJsonBody;

    // Restore all enum-based selections.
    _method = preset.method;
    _authType = preset.authType;
    _apiKeyPlacement = preset.apiKeyPlacement;
    _bodyType = preset.bodyType;
    _endpointType = preset.endpointType;

    // Replace KV lists completely — no merging with old state.
    _headers = List.of(preset.headers);
    _queryParams = List.of(preset.queryParams);
    _pathParams = List.of(preset.pathParams);
    _formFields = List.of(preset.formFields);

    // Clear request lifecycle state for a clean fresh start.
    _requestState = const IdleState();
    _lastTrace = null;
    _jsonError = null;
    _validationError = null;
    _tokenExtractionError = null;
    _lastSendWasTokenEndpoint = false;

    // Bump the reset key so all KVTable widgets reinitialize from the new data.
    _resetKey++;
    _isRestoring = false;

    // Persist the newly loaded state as the active draft for cross-session continuity.
    _scheduleSave();
    notifyListeners();
  }
}
