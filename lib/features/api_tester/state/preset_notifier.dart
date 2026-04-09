// preset_notifier.dart
// Purpose: ChangeNotifier managing the list of saved presets — full request snapshot save, load, and delete.

import 'dart:math';

import 'package:flutter/material.dart';

import '../data/preset_storage.dart';
import '../domain/models/preset.dart';
import 'api_tester_notifier.dart';

class PresetNotifier extends ChangeNotifier {
  List<Preset> _presets = [];

  List<Preset> get presets => List.unmodifiable(_presets);
  bool get hasPresets => _presets.isNotEmpty;

  PresetNotifier() {
    _load();
  }

  Future<void> _load() async {
    _presets = await PresetStorage.load();
    notifyListeners();
  }

  /// Captures the full current request state from [notifier] and saves it as a named preset.
  /// Every field of the request form is stored so that loading this preset later
  /// produces an exact restoration — not a partial overlay.
  Future<void> saveFromNotifier(String name, ApiTesterNotifier notifier) async {
    final preset = Preset(
      id: _generateId(),
      name: name.trim().isEmpty ? 'Unnamed' : name.trim(),
      createdAt: DateTime.now(),
      baseUrl: notifier.baseUrlController.text,
      endpoint: notifier.endpointController.text,
      method: notifier.method,
      endpointType: notifier.endpointType,
      authType: notifier.authType,
      apiKeyPlacement: notifier.apiKeyPlacement,
      username: notifier.usernameController.text,
      password: notifier.passwordController.text,
      token: notifier.tokenController.text,
      apiKeyName: notifier.apiKeyNameController.text,
      apiKeyValue: notifier.apiKeyValueController.text,
      headers: List.of(notifier.headers),
      queryParams: List.of(notifier.queryParams),
      pathParams: List.of(notifier.pathParams),
      formFields: List.of(notifier.formFields),
      bodyType: notifier.bodyType,
      rawJsonBody: notifier.rawJsonController.text,
    );
    _presets = [preset, ..._presets];
    notifyListeners();
    await PresetStorage.save(_presets);
  }

  /// Removes the preset with the given [id].
  Future<void> delete(String id) async {
    _presets = _presets.where((p) => p.id != id).toList();
    notifyListeners();
    await PresetStorage.save(_presets);
  }

  /// Loads [preset] into [notifier] as an exact snapshot, fully replacing all current
  /// request form state. No merging — the old state is cleared before the preset is applied.
  void apply(Preset preset, ApiTesterNotifier notifier) {
    notifier.loadFromPreset(preset);
  }

  static String _generateId() {
    final rng = Random.secure();
    return List.generate(12, (_) => rng.nextInt(36).toRadixString(36)).join();
  }
}
