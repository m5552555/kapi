// api_tester_notifier.dart
// Purpose: ChangeNotifier that owns all request-form state, executes requests, manages the request lifecycle,
//          token capture/injection for the guided token flow, and auto-saves/restores the last draft.

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/utils/json_utils.dart';
import '../../../core/utils/request_trace_builder.dart';
import '../../../core/utils/url_utils.dart';
import '../data/draft_storage.dart';
import '../data/error_interpreter.dart';
import '../data/request_executor.dart';
import '../data/token_extractor.dart';
import '../domain/models/api_request.dart';
import '../domain/models/auth_config.dart';
import '../domain/models/captured_token.dart';
import '../domain/models/endpoint_type.dart';
import '../domain/models/kv_pair.dart';
import '../domain/models/request_draft.dart';
import '../domain/models/request_state.dart';
import '../domain/models/request_trace.dart';

class ApiTesterNotifier extends ChangeNotifier {
  // ─── Text controllers (owned by notifier for lifecycle & reset) ──────────────

  final TextEditingController baseUrlController = TextEditingController();
  final TextEditingController endpointController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController apiKeyNameController = TextEditingController();
  final TextEditingController apiKeyValueController = TextEditingController();
  final TextEditingController rawJsonController = TextEditingController();

  // ─── Selectable values ────────────────────────────────────────────────────────

  HttpMethod _method = HttpMethod.get;
  AuthType _authType = AuthType.none;
  ApiKeyPlacement _apiKeyPlacement = ApiKeyPlacement.header;
  BodyType _bodyType = BodyType.none;

  // ─── Endpoint classification (token flow) ────────────────────────────────────

  EndpointType _endpointType = EndpointType.normal;

  // ─── Captured token (session-only; not persisted to draft) ───────────────────

  CapturedToken? _capturedToken;

  // Tracks whether the most recent send attempt was a Token Endpoint request.
  // Used to decide whether to show the token capture panel in the response area.
  bool _lastSendWasTokenEndpoint = false;

  // Set when the last Token Endpoint response did not contain a recognizable token.
  String? _tokenExtractionError;

  // ─── Key-value lists ─────────────────────────────────────────────────────────

  List<KVPair> _headers = [];
  List<KVPair> _queryParams = [];
  List<KVPair> _pathParams = [];
  List<KVPair> _formFields = [];

  // ─── Request lifecycle ────────────────────────────────────────────────────────

  RequestState _requestState = const IdleState();

  // Wire-level snapshot built before each send (kept even on failure).
  RequestTrace? _lastTrace;

  // ─── Validation ───────────────────────────────────────────────────────────────

  String? _jsonError;
  String? _validationError;

  // ─── Reset signaling ──────────────────────────────────────────────────────────

  int _resetKey = 0;

  // ─── Persistence internals ────────────────────────────────────────────────────

  bool _isRestoring = false;
  Timer? _saveDebounce;

  // ─── Constructor ─────────────────────────────────────────────────────────────

  ApiTesterNotifier() {
    _attachSaveListeners();
    _loadAndRestoreDraft();
  }

  // ─── Getters ─────────────────────────────────────────────────────────────────

  HttpMethod get method => _method;
  AuthType get authType => _authType;
  ApiKeyPlacement get apiKeyPlacement => _apiKeyPlacement;
  BodyType get bodyType => _bodyType;
  EndpointType get endpointType => _endpointType;
  CapturedToken? get capturedToken => _capturedToken;
  bool get hasToken => _capturedToken != null;
  bool get lastSendWasTokenEndpoint => _lastSendWasTokenEndpoint;
  String? get tokenExtractionError => _tokenExtractionError;
  List<KVPair> get headers => List.unmodifiable(_headers);
  List<KVPair> get queryParams => List.unmodifiable(_queryParams);
  List<KVPair> get pathParams => List.unmodifiable(_pathParams);
  List<KVPair> get formFields => List.unmodifiable(_formFields);
  RequestState get requestState => _requestState;
  RequestTrace? get lastTrace => _lastTrace;
  String? get jsonError => _jsonError;
  String? get validationError => _validationError;
  int get resetKey => _resetKey;
  bool get isLoading => _requestState is LoadingState;

  // ─── Endpoint type ────────────────────────────────────────────────────────────

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

  // ─── Method / Auth / Body type setters ───────────────────────────────────────

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

  // ─── JSON validation ──────────────────────────────────────────────────────────

  void validateJsonBody() {
    final error = JsonUtils.validateJson(rawJsonController.text);
    if (_jsonError == error) return;
    _jsonError = error;
    notifyListeners();
  }

  void formatJsonBody() {
    final formatted = JsonUtils.tryFormat(rawJsonController.text);
    if (formatted != null) {
      rawJsonController.value = rawJsonController.value.copyWith(text: formatted);
      _jsonError = null;
      notifyListeners();
    }
  }

  // ─── KV list mutators ────────────────────────────────────────────────────────

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

  // ─── Endpoint change: auto-detect path placeholders ──────────────────────────

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

  // ─── Send request ─────────────────────────────────────────────────────────────

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

  // ─── Reset ───────────────────────────────────────────────────────────────────

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

  // ─── Persistence ─────────────────────────────────────────────────────────────

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

  void _attachSaveListeners() {
    for (final ctrl in _allControllers) {
      ctrl.addListener(_scheduleSave);
    }
  }

  // ─── Private helpers ─────────────────────────────────────────────────────────

  static T _enumByName<T extends Enum>(List<T> values, String name, T fallback) {
    return values.where((e) => e.name == name).firstOrNull ?? fallback;
  }

  List<TextEditingController> get _allControllers => [
        baseUrlController,
        endpointController,
        usernameController,
        passwordController,
        tokenController,
        apiKeyNameController,
        apiKeyValueController,
        rawJsonController,
      ];

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

  // ─── Disposal ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _saveDebounce?.cancel();
    for (final ctrl in _allControllers) {
      ctrl.removeListener(_scheduleSave);
      ctrl.dispose();
    }
    super.dispose();
  }
}
