part of 'package:kapi/features/api_tester/state/api_tester_notifier.dart';

// Purpose: Draft load/save/restore mixin — debounced auto-save of the request form to disk
// Keywords: persistence, draft, debounce, save, restore, mixin

/// Persistence: attaches controllers to a debounced save, loads the last
/// draft at startup, and writes a new draft on every change.
mixin _PersistenceMixin on _ApiTesterState {
  void _attachSaveListeners() {
    for (final ctrl in _allControllers) {
      ctrl.addListener(_scheduleSave);
    }
  }

  Future<void> _loadAndRestoreDraft() async {
    final draft = await DraftStorage.load();
    if (draft == null) return;
    _applyDraft(draft);
    notifyListeners();
  }

  void _applyDraft(RequestDraft draft) {
    _isRestoring = true;

    baseUrlController.text = draft.baseUrl;
    endpointController.text = draft.endpoint;
    usernameController.text = draft.username;
    passwordController.text = draft.password;
    tokenController.text = draft.token;
    apiKeyNameController.text = draft.apiKeyName;
    apiKeyValueController.text = draft.apiKeyValue;
    rawJsonController.text = draft.rawJsonBody;

    _method = _enumByName(HttpMethod.values, draft.method, HttpMethod.get);
    _authType = _enumByName(AuthType.values, draft.authType, AuthType.none);
    _apiKeyPlacement = _enumByName(
      ApiKeyPlacement.values,
      draft.apiKeyPlacement,
      ApiKeyPlacement.header,
    );
    _bodyType = _enumByName(BodyType.values, draft.bodyType, BodyType.none);
    _endpointType = _enumByName(
      EndpointType.values,
      draft.endpointType,
      EndpointType.normal,
    );

    _headers = List.of(draft.headers);
    _queryParams = List.of(draft.queryParams);
    _pathParams = List.of(draft.pathParams);
    _formFields = List.of(draft.formFields);

    _resetKey++;
    _isRestoring = false;
  }

  void _scheduleSave() {
    if (_isRestoring) return;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), _saveDraft);
  }

  Future<void> _saveDraft() async {
    await DraftStorage.save(_buildDraft());
  }

  RequestDraft _buildDraft() {
    return RequestDraft(
      baseUrl: baseUrlController.text,
      endpoint: endpointController.text,
      method: _method.name,
      authType: _authType.name,
      apiKeyPlacement: _apiKeyPlacement.name,
      username: usernameController.text,
      password: passwordController.text,
      token: tokenController.text,
      apiKeyName: apiKeyNameController.text,
      apiKeyValue: apiKeyValueController.text,
      headers: List.of(_headers),
      queryParams: List.of(_queryParams),
      pathParams: List.of(_pathParams),
      formFields: List.of(_formFields),
      bodyType: _bodyType.name,
      rawJsonBody: rawJsonController.text,
      endpointType: _endpointType.name,
    );
  }
}
