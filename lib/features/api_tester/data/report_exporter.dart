// report_exporter.dart
// Purpose: Generates a self-contained HTML API test report and saves it to the user's Documents folder.

import 'dart:convert';
import 'dart:io';

import '../../../core/utils/json_utils.dart';
import '../domain/models/api_response.dart';
import '../domain/models/app_error.dart';
import '../domain/models/request_state.dart';
import '../domain/models/request_trace.dart';

abstract final class ReportExporter {
  /// Generates an HTML report from the last request/response result and writes it to
  /// `%USERPROFILE%\Documents\Kapi Reports\kapi_report_{endpoint}_{timestamp}.html`.
  ///
  /// Returns the absolute path of the saved file on success, or null on failure.
  static Future<String?> export({
    required RequestTrace? trace,
    required RequestState state,
    required String notes,
    required String endpoint,
    required String baseUrl,
  }) async {
    try {
      final now = DateTime.now();
      final html = _buildHtml(
        trace: trace,
        state: state,
        notes: notes,
        endpoint: endpoint,
        baseUrl: baseUrl,
        reportTime: now,
      );

      final fileName =
          'kapi_report_${_sanitize(endpoint.isEmpty ? 'request' : endpoint)}_${_ts(now)}.html';
      final dir = _reportsDir();
      await dir.create(recursive: true);
      final file = File('${dir.path}${Platform.pathSeparator}$fileName');
      await file.writeAsString(html, encoding: utf8);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  // ─── Path helpers ─────────────────────────────────────────────────────────────

  static Directory _reportsDir() {
    final home = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '.';
    return Directory(
        '$home${Platform.pathSeparator}Documents${Platform.pathSeparator}Kapi Reports');
  }

  static String _ts(DateTime dt) =>
      '${dt.year}${_p(dt.month)}${_p(dt.day)}_${_p(dt.hour)}${_p(dt.minute)}${_p(dt.second)}';

  static String _p(int n) => n.toString().padLeft(2, '0');

  static String _sanitize(String s) => s
      .replaceAll(RegExp(r'[/\\:*?"<>|]'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  // ─── HTML generation ─────────────────────────────────────────────────────────

  static String _buildHtml({
    required RequestTrace? trace,
    required RequestState state,
    required String notes,
    required String endpoint,
    required String baseUrl,
    required DateTime reportTime,
  }) {
    final isSuccess = state is SuccessState;
    final isFail = state is FailureState;
    final ApiResponse? response = isSuccess ? state.response : null;
    final AppError? error = isFail ? state.error : null;

    final resultClass = isSuccess ? 'success' : 'failure';
    final resultText = isSuccess
        ? 'The API test completed successfully.'
        : isFail
            ? 'The API request failed. ${_e(error!.meaning)}'
            : 'Outcome unknown.';

    final buf = StringBuffer();

    // ── Document head ──────────────────────────────────────────────────────────
    buf.write('''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>API Test Report</title>
<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',system-ui,sans-serif;background:#080808;color:#dde8dd;padding:40px 32px;line-height:1.65;font-size:13px}
.wrap{max-width:940px;margin:0 auto}
h1{font-size:24px;font-weight:700;color:#4CAF50;letter-spacing:.4px}
.meta{font-size:11px;color:#555;margin-top:4px}
hr{border:none;border-top:2px solid #4CAF50;margin:20px 0 28px}
.section{margin-bottom:26px}
.section-title{font-size:10px;font-weight:700;letter-spacing:1.4px;color:#4CAF50;text-transform:uppercase;border-bottom:1px solid #182818;padding-bottom:5px;margin-bottom:10px}
.kv{display:flex;padding:5px 0;border-bottom:1px solid #101010}
.kv:last-child{border-bottom:none}
.kl{width:190px;min-width:190px;color:#6a8a6a;font-size:11px;padding-right:8px}
.kv2{color:#dde8dd;font-size:12px;word-break:break-all}
.kv2.mono{font-family:'Cascadia Code','Consolas',monospace;color:#c8eec8}
table{width:100%;border-collapse:collapse;font-size:11px;margin-bottom:4px}
th{text-align:left;padding:7px 10px;background:#0c1a0c;color:#4CAF50;font-size:10px;letter-spacing:.8px;text-transform:uppercase;border-bottom:1px solid #1e2e1e}
td{padding:7px 10px;border-bottom:1px solid #0d0d0d;font-family:'Cascadia Code','Consolas',monospace;color:#c8d8c8;word-break:break-all;vertical-align:top}
tr:nth-child(even) td{background:#0a100a}
tr:last-child td{border-bottom:none}
.result{padding:14px 18px;border-radius:6px;border:1px solid;margin-bottom:24px;font-size:13px;font-weight:500}
.result.success{background:#091509;border-color:#2e7d32;color:#69F0AE}
.result.failure{background:#130808;border-color:#7d2020;color:#EF9A9A}
.result-icon{margin-right:8px;font-size:16px}
.status-badge{display:inline-block;padding:3px 10px;border-radius:3px;font-family:monospace;font-weight:700;font-size:13px;margin-bottom:10px}
.s2xx{background:#0d1f0d;color:#69F0AE;border:1px solid #2e7d32}
.serr{background:#1f0d0d;color:#EF9A9A;border:1px solid #7d2020}
.body-pre{background:#050505;border:1px solid #182818;border-radius:4px;padding:14px;font-family:'Cascadia Code','Consolas',monospace;font-size:11px;color:#c8eec8;white-space:pre-wrap;word-break:break-all;overflow-wrap:anywhere;margin-top:6px}
.notes-box{background:#0a0a0a;border:1px solid #181818;border-radius:4px;padding:12px;color:#888;font-size:12px;white-space:pre-wrap;min-height:36px}
.footer{margin-top:36px;padding-top:14px;border-top:1px solid #182818;text-align:center;color:#3a5a3a;font-size:11px}
.footer strong{color:#4CAF50}
</style>
</head>
<body>
<div class="wrap">
''');

    // ── Header ─────────────────────────────────────────────────────────────────
    buf.write('<h1>API Test Report</h1>\n');
    buf.write(
        '<p class="meta">Generated by Kapi &bull; ${_e(reportTime.toLocal().toString().substring(0, 19))}</p>\n');
    buf.write('<hr>\n\n');

    // ── Result summary ─────────────────────────────────────────────────────────
    buf.write('<div class="result $resultClass">');
    buf.write('<span class="result-icon">${isSuccess ? '✓' : '✗'}</span>$resultText');
    buf.write('</div>\n\n');

    // ── API Identity ───────────────────────────────────────────────────────────
    buf.write('<div class="section">\n<div class="section-title">API Identity</div>\n');
    if (trace != null) {
      buf.write(_kv('Full URL', trace.fullUrl, mono: true));
    } else {
      buf.write(_kv('Base URL', baseUrl, mono: true));
      buf.write(_kv('Endpoint', endpoint, mono: true));
    }
    buf.write(_kv('HTTP Method', trace?.method ?? '-'));
    buf.write(_kv('Timestamp', reportTime.toLocal().toString().substring(0, 19)));
    buf.write('</div>\n\n');

    // ── Request headers ────────────────────────────────────────────────────────
    if (trace != null && trace.sentHeaders.isNotEmpty) {
      buf.write('<div class="section">\n<div class="section-title">Request Headers Sent</div>\n');
      buf.write('<table><thead><tr><th>Header Name</th><th>Value</th></tr></thead><tbody>\n');
      for (final entry in trace.sentHeaders.entries) {
        buf.write('<tr><td>${_e(entry.key)}</td><td>${_e(entry.value)}</td></tr>\n');
      }
      buf.write('</tbody></table>\n</div>\n\n');
    }

    // ── Request body ───────────────────────────────────────────────────────────
    if (trace != null) {
      buf.write('<div class="section">\n<div class="section-title">Request Body</div>\n');
      buf.write(_kv('Body Type', trace.bodyType));
      if (trace.bodyText.isNotEmpty) {
        buf.write('<div class="body-pre">${_e(trace.bodyText)}</div>\n');
      } else {
        buf.write(_kv('Payload', 'None'));
      }
      buf.write('</div>\n\n');
    }

    // ── Response ───────────────────────────────────────────────────────────────
    buf.write('<div class="section">\n<div class="section-title">Response</div>\n');
    if (response != null) {
      final badgeClass = response.isSuccess ? 's2xx' : 'serr';
      buf.write(
          '<span class="status-badge $badgeClass">${response.statusCode} ${_e(response.statusMessage)}</span>\n');
      buf.write(_kv('Duration', JsonUtils.formatDuration(response.duration)));
      buf.write(_kv('Size', JsonUtils.formatSize(response.sizeBytes)));

      if (response.headers.isNotEmpty) {
        buf.write('<br><table><thead><tr><th>Response Header</th><th>Value</th></tr></thead><tbody>\n');
        final sorted = response.headers.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        for (final e in sorted) {
          buf.write('<tr><td>${_e(e.key)}</td><td>${_e(e.value)}</td></tr>\n');
        }
        buf.write('</tbody></table>\n');
      }

      if (response.body.isNotEmpty) {
        buf.write('<div class="body-pre">${_e(response.body)}</div>\n');
      }
    } else if (error != null) {
      buf.write(_kv('Error', error.technical, mono: true));
      buf.write(_kv('What happened', error.meaning));
      buf.write(_kv('Likely cause', error.likelyCause));
      buf.write(_kv('Try next', error.nextStep));
    }
    buf.write('</div>\n\n');

    // ── Test details ───────────────────────────────────────────────────────────
    buf.write('<div class="section">\n<div class="section-title">Test Details</div>\n');
    buf.write(_kv('Tested at', reportTime.toLocal().toString().substring(0, 19)));
    if (response != null) {
      buf.write(_kv('Duration', JsonUtils.formatDuration(response.duration)));
      buf.write(_kv('Outcome', response.isSuccess ? 'Success' : 'HTTP error ${response.statusCode}'));
    } else if (error != null) {
      buf.write(_kv('Outcome', 'Connection failed — ${error.category.name}'));
    }
    if (trace != null) {
      buf.write(_kv('Headers sent', '${trace.sentHeaders.length}'));
      buf.write(_kv('Body encoding', trace.bodyType));
    }
    buf.write('</div>\n\n');

    // ── Notes ──────────────────────────────────────────────────────────────────
    buf.write('<div class="section">\n<div class="section-title">Tester Notes</div>\n');
    final notesTrimmed = notes.trim();
    buf.write('<div class="notes-box">');
    buf.write(notesTrimmed.isEmpty ? 'No additional notes provided.' : _e(notesTrimmed));
    buf.write('</div>\n</div>\n\n');

    // ── Footer ─────────────────────────────────────────────────────────────────
    buf.write('<div class="footer"><strong>Kapi</strong> &bull; Made by Mohamed Khallaf 2026</div>\n');

    buf.write('\n</div>\n</body>\n</html>\n');

    return buf.toString();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  static String _kv(String label, String value, {bool mono = false}) {
    return '<div class="kv"><div class="kl">${_e(label)}</div>'
        '<div class="kv2${mono ? ' mono' : ''}">${_e(value)}</div></div>\n';
  }

  /// Escapes HTML special characters.
  static String _e(String text) => text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}
