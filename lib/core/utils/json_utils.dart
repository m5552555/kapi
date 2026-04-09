// json_utils.dart
// Purpose: JSON validation, pretty-printing, and format detection utilities.

import 'dart:convert';

abstract final class JsonUtils {
  static const _encoder = JsonEncoder.withIndent('  ');

  /// Returns formatted JSON or null if input is not valid JSON.
  static String? tryFormat(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return _encoder.convert(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Returns a human-readable error description for invalid JSON.
  static String? validateJson(String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      jsonDecode(raw);
      return null;
    } on FormatException catch (e) {
      return _describeFormatException(e, raw);
    }
  }

  static String _describeFormatException(FormatException e, String raw) {
    if (e.offset != null) {
      final offset = e.offset!;
      final lines = raw.substring(0, offset).split('\n');
      final line = lines.length;
      final col = lines.last.length + 1;
      return 'JSON syntax error at line $line, column $col: ${_cleanMessage(e.message)}';
    }
    return 'JSON syntax error: ${_cleanMessage(e.message)}';
  }

  static String _cleanMessage(String message) {
    return message.replaceFirst('FormatException: ', '').trim();
  }

  /// Returns formatted JSON, falling back to the raw string if unparseable.
  static String formatOrRaw(String raw) => tryFormat(raw) ?? raw;

  /// Returns true if the content-type header indicates JSON.
  static bool isJsonContentType(String? contentType) {
    if (contentType == null) return false;
    return contentType.contains('application/json') ||
        contentType.contains('+json');
  }

  /// Attempts to detect if a string is JSON even without a content-type header.
  static bool looksLikeJson(String body) {
    final trimmed = body.trimLeft();
    return trimmed.startsWith('{') || trimmed.startsWith('[');
  }

  /// Formats a byte count into a human-friendly size string.
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Formats a Duration into a milliseconds display string.
  static String formatDuration(Duration d) {
    final ms = d.inMilliseconds;
    if (ms < 1000) return '$ms ms';
    return '${(ms / 1000).toStringAsFixed(2)} s';
  }
}
