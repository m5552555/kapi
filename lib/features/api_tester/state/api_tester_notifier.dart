// File: lib/features/api_tester/state/api_tester_notifier.dart
// Purpose: ChangeNotifier composing all request-form state, lifecycle, and persistence via mixins
// Keywords: notifier, state, mixin, part, change-notifier, library

library api_tester_notifier;

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
import '../domain/models/preset.dart';
import '../domain/models/request_draft.dart';
import '../domain/models/request_state.dart';
import '../domain/models/request_trace.dart';

part 'notifier/_inputs_mixin.dart';
part 'notifier/_send_mixin.dart';
part 'notifier/_actions_mixin.dart';
part 'notifier/_persistence_mixin.dart';

// Internal helper shared across the library — converts an enum name (stored
// in drafts/presets) back to its enum value with a safe fallback.
T _enumByName<T extends Enum>(List<T> values, String name, T fallback) =>
    values.where((e) => e.name == name).firstOrNull ?? fallback;

/// Shared state base for [ApiTesterNotifier]. Holds every field touched by
/// the mixins so they can read and write through the same library scope.
abstract class _ApiTesterState extends ChangeNotifier {
  // Text controllers (owned by notifier for lifecycle & reset).
  final TextEditingController baseUrlController = TextEditingController();
  final TextEditingController endpointController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController apiKeyNameController = TextEditingController();
  final TextEditingController apiKeyValueController = TextEditingController();
  final TextEditingController rawJsonController = TextEditingController();

  // Selectable enum values.
  HttpMethod _method = HttpMethod.get;
  AuthType _authType = AuthType.none;
  ApiKeyPlacement _apiKeyPlacement = ApiKeyPlacement.header;
  BodyType _bodyType = BodyType.none;

  // Endpoint classification (token flow).
  EndpointType _endpointType = EndpointType.normal;

  // Captured token (session-only; not persisted to draft).
  CapturedToken? _capturedToken;
  bool _lastSendWasTokenEndpoint = false;
  String? _tokenExtractionError;

  // Key-value lists.
  List<KVPair> _headers = [];
  List<KVPair> _queryParams = [];
  List<KVPair> _pathParams = [];
  List<KVPair> _formFields = [];

  // Request lifecycle.
  RequestState _requestState = const IdleState();
  RequestTrace? _lastTrace;

  // Validation messages.
  String? _jsonError;
  String? _validationError;

  // Reset signaling — bumped to force KVTable widgets to reinitialize.
  int _resetKey = 0;

  // Persistence internals.
  bool _isRestoring = false;
  String? _editingPresetId;
  String? _editingPresetName;
  Timer? _saveDebounce;

  // Every text controller in one place — used for listener wiring & disposal.
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

  // Implemented by _PersistenceMixin — declared here so other mixins can call it.
  void _scheduleSave();
}

/// Public notifier exposed to widgets. Behavior is composed from the
/// part-file mixins (inputs, send, actions, persistence). The `with` clause
/// is intentionally omitted at this checkpoint and will be added once the
/// four mixin part files exist.
class ApiTesterNotifier extends _ApiTesterState
    with _PersistenceMixin, _InputsMixin, _SendMixin, _ActionsMixin {
  ApiTesterNotifier() {
    _attachSaveListeners();
    _loadAndRestoreDraft();
  }

  // Enum / endpoint getters.
  HttpMethod get method => _method;
  AuthType get authType => _authType;
  ApiKeyPlacement get apiKeyPlacement => _apiKeyPlacement;
  BodyType get bodyType => _bodyType;
  EndpointType get endpointType => _endpointType;

  // Token getters.
  CapturedToken? get capturedToken => _capturedToken;
  bool get hasToken => _capturedToken != null;
  bool get lastSendWasTokenEndpoint => _lastSendWasTokenEndpoint;
  String? get tokenExtractionError => _tokenExtractionError;

  // KV list getters (unmodifiable views).
  List<KVPair> get headers => List.unmodifiable(_headers);
  List<KVPair> get queryParams => List.unmodifiable(_queryParams);
  List<KVPair> get pathParams => List.unmodifiable(_pathParams);
  List<KVPair> get formFields => List.unmodifiable(_formFields);

  // Lifecycle getters.
  RequestState get requestState => _requestState;
  RequestTrace? get lastTrace => _lastTrace;
  bool get isLoading => _requestState is LoadingState;

  // Validation getters.
  String? get jsonError => _jsonError;
  String? get validationError => _validationError;

  // Reset key getter.
  int get resetKey => _resetKey;

  // Editing-preset getters.
  String? get editingPresetId => _editingPresetId;
  String? get editingPresetName => _editingPresetName;
  bool get isEditingPreset => _editingPresetId != null;

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
