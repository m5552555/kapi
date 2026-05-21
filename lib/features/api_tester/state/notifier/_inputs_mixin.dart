part of 'package:kapi/features/api_tester/state/api_tester_notifier.dart';

// Purpose: Inputs mixin — setters, KV updaters, JSON validation, endpoint-change auto-detect
// Keywords: inputs, setters, kv, validation, endpoint-change, mixin

/// Inputs: mutates form-side state in response to user actions and notifies
/// listeners. Every mutating method also schedules a draft save.
mixin _InputsMixin on _ApiTesterState {
  // ─── Method / Auth / Body / Endpoint type setters ──────────────────────────

  void setMethod(HttpMethod method) {
    if (_method == method) return;
    _method = method;
    _scheduleSave();
    notifyListeners();
  }

  void setAuthType(AuthType type) {
    if (_authType == type) return;
    _authType = type;
    _scheduleSave();
    notifyListeners();
  }

  void setApiKeyPlacement(ApiKeyPlacement placement) {
    if (_apiKeyPlacement == placement) return;
    _apiKeyPlacement = placement;
    _scheduleSave();
    notifyListeners();
  }

  void setBodyType(BodyType type) {
    if (_bodyType == type) return;
    _bodyType = type;
    _scheduleSave();
    notifyListeners();
  }

  void setEndpointType(EndpointType type) {
    if (_endpointType == type) return;
    _endpointType = type;
    // Clear extraction error when type changes — it belongs to the previous send.
    _tokenExtractionError = null;
    _scheduleSave();
    notifyListeners();
  }

  /// Removes the currently stored token (e.g. user explicitly clears it).
  void clearCapturedToken() {
    _capturedToken = null;
    _tokenExtractionError = null;
    notifyListeners();
  }

  // ─── KV list mutators ──────────────────────────────────────────────────────

  void updateHeaders(List<KVPair> updated) {
    _headers = List.of(updated);
    _scheduleSave();
    notifyListeners();
  }

  void updateQueryParams(List<KVPair> updated) {
    _queryParams = List.of(updated);
    _scheduleSave();
    notifyListeners();
  }

  void updatePathParams(List<KVPair> updated) {
    _pathParams = List.of(updated);
    _scheduleSave();
    notifyListeners();
  }

  void updateFormFields(List<KVPair> updated) {
    _formFields = List.of(updated);
    _scheduleSave();
    notifyListeners();
  }

  // ─── Endpoint change: auto-detect path placeholders ────────────────────────

  void onEndpointChanged(String endpoint) {
    final placeholders = UrlUtils.extractPathPlaceholders(endpoint);
    if (placeholders.isNotEmpty) {
      final existing = _pathParams.map((p) => p.key).toSet();
      final added = placeholders.where((p) => !existing.contains(p));
      if (added.isNotEmpty) {
        _pathParams = [
          ..._pathParams,
          ...added.map((p) => KVPair(key: p, value: '')),
        ];
        _scheduleSave();
        notifyListeners();
      }
    }
  }

  // ─── JSON validation ───────────────────────────────────────────────────────

  void validateJsonBody() {
    final error = JsonUtils.validateJson(rawJsonController.text);
    if (_jsonError == error) return;
    _jsonError = error;
    notifyListeners();
  }

  void formatJsonBody() {
    final formatted = JsonUtils.tryFormat(rawJsonController.text);
    if (formatted != null) {
      rawJsonController.value =
          rawJsonController.value.copyWith(text: formatted);
      _jsonError = null;
      notifyListeners();
    }
  }
}
