// preset_notifier.dart
// Purpose: ChangeNotifier managing the list of user-defined presets with load, save, apply, and delete operations.

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

  /// Saves the current state of [notifier] as a new named preset.
  Future<void> saveFromNotifier(String name, ApiTesterNotifier notifier) async {
    final preset = Preset(
      id: _generateId(),
      name: name.trim().isEmpty ? 'Unnamed' : name.trim(),
      createdAt: DateTime.now(),
      baseUrl: notifier.baseUrlController.text,
      authType: notifier.authType,
      apiKeyPlacement: notifier.apiKeyPlacement,
      username: notifier.usernameController.text,
      password: notifier.passwordController.text,
      token: notifier.tokenController.text,
      apiKeyName: notifier.apiKeyNameController.text,
      apiKeyValue: notifier.apiKeyValueController.text,
      headers: List.of(notifier.headers),
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

  /// Applies all values from [preset] into [notifier].
  /// Only overwrites non-empty fields so the user's current work is preserved where possible.
  void apply(Preset preset, ApiTesterNotifier notifier) {
    if (preset.baseUrl.isNotEmpty) {
      notifier.baseUrlController.text = preset.baseUrl;
    }
    notifier.setAuthType(preset.authType);
    notifier.setApiKeyPlacement(preset.apiKeyPlacement);
    notifier.usernameController.text = preset.username;
    notifier.passwordController.text = preset.password;
    notifier.tokenController.text = preset.token;
    notifier.apiKeyNameController.text = preset.apiKeyName;
    notifier.apiKeyValueController.text = preset.apiKeyValue;
    if (preset.headers.isNotEmpty) {
      notifier.updateHeaders(preset.headers);
    }
  }

  static String _generateId() {
    final rng = Random.secure();
    return List.generate(12, (_) => rng.nextInt(36).toRadixString(36)).join();
  }
}
