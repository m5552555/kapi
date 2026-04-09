// preset_storage.dart
// Purpose: Reads and writes the list of user-defined presets to a local JSON file.

import 'dart:convert';
import 'dart:io';

import '../domain/models/preset.dart';

abstract final class PresetStorage {
  static const String _dirName = 'Kapi';
  static const String _fileName = 'presets.json';

  /// Loads all saved presets. Returns an empty list if the file does not exist or is corrupt.
  static Future<List<Preset>> load() async {
    try {
      final file = _file();
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final json = jsonDecode(content);
      if (json is! List) return [];
      return json
          .whereType<Map<String, dynamic>>()
          .map(Preset.fromJson)
          .whereType<Preset>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists the full preset list to disk. Failures are silently ignored.
  static Future<void> save(List<Preset> presets) async {
    try {
      final file = _file();
      await file.parent.create(recursive: true);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ')
            .convert(presets.map((p) => p.toJson()).toList()),
        flush: true,
      );
    } catch (_) {}
  }

  static File _file() {
    final appData = Platform.environment['APPDATA'];
    final sep = Platform.pathSeparator;
    final dir = appData != null ? '$appData$sep$_dirName' : '.${sep}kapi_data';
    return File('$dir$sep$_fileName');
  }
}
