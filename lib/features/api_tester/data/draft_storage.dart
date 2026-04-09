// draft_storage.dart
// Purpose: Reads and writes the last request draft to a local JSON file in the user's app-data directory.

import 'dart:convert';
import 'dart:io';

import '../domain/models/request_draft.dart';

/// Manages persistence of the last request draft using a single JSON file
/// stored under %APPDATA%\Kapi\ on Windows.
/// All methods are fail-safe: I/O errors are caught and swallowed silently
/// so that a persistence failure never crashes or blocks the app.
abstract final class DraftStorage {
  static const String _dirName = 'Kapi';
  static const String _fileName = 'draft.json';

  // ─── Public API ──────────────────────────────────────────────────────────────

  /// Loads and deserializes the saved draft.
  /// Returns null if no draft exists, the file is corrupt, or any I/O error occurs.
  static Future<RequestDraft?> load() async {
    try {
      final file = _draftFile();
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      final json = jsonDecode(content);
      if (json is! Map<String, dynamic>) return null;
      return RequestDraft.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Serializes and writes the draft to disk.
  /// Creates the parent directory if it does not exist.
  /// Failures are silently ignored — persistence is best-effort.
  static Future<void> save(RequestDraft draft) async {
    try {
      final file = _draftFile();
      await file.parent.create(recursive: true);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(draft.toJson()),
        flush: true,
      );
    } catch (_) {
      // Best-effort: never crash the app because of a save failure.
    }
  }

  /// Deletes the draft file so that the next launch starts fresh.
  /// Failures are silently ignored.
  static Future<void> clear() async {
    try {
      final file = _draftFile();
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  // ─── Path resolution ──────────────────────────────────────────────────────────

  static File _draftFile() {
    final appData = Platform.environment['APPDATA'];
    final sep = Platform.pathSeparator;
    final dirPath = appData != null
        ? '$appData$sep$_dirName'
        : '.${sep}kapi_data'; // Fallback for non-Windows envs during testing
    return File('$dirPath$sep$_fileName');
  }
}
