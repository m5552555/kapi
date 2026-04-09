// status_bar.dart
// Purpose: Displays HTTP status code, status message, response time, and size in a compact summary bar.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/models/api_response.dart';
import '../shared/copy_button.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key, required this.response});
  final ApiResponse response;

  static Color _statusColor(int code) {
    if (code >= 500) return AppColors.status5xx;
    if (code >= 400) return AppColors.status4xx;
    if (code >= 300) return AppColors.status3xx;
    return AppColors.status2xx;
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(response.statusCode);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Status code badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${response.statusCode}',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          // Status message
          Expanded(
            child: Text(
              response.statusMessage,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Timing
          _MetaChip(
            icon: Icons.timer_outlined,
            value: JsonUtils.formatDuration(response.duration),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          // Size
          _MetaChip(
            icon: Icons.data_usage_rounded,
            value: JsonUtils.formatSize(response.sizeBytes),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          // Copy URL button
          CopyButton(
            getText: () => response.fullUrl,
            tooltip: 'Copy full URL',
            feedback: 'URL copied',
          ),
          const SizedBox(width: AppConstants.spacingXs),
          // Copy All button
          CopyButton(
            getText: () => _buildCopyAll(response),
            tooltip: 'Copy full response',
            feedback: 'Response copied',
            withLabel: true,
          ),
        ],
      ),
    );
  }

  static String _buildCopyAll(ApiResponse r) {
    final buf = StringBuffer();
    buf.writeln('URL: ${r.fullUrl}');
    buf.writeln('Status: ${r.statusCode} ${r.statusMessage}');
    buf.writeln('Duration: ${JsonUtils.formatDuration(r.duration)}  Size: ${JsonUtils.formatSize(r.sizeBytes)}');
    buf.writeln();
    buf.writeln('HEADERS:');
    final sorted = r.headers.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    for (final e in sorted) {
      buf.writeln('${e.key}: ${e.value}');
    }
    if (r.body.isNotEmpty) {
      buf.writeln();
      buf.writeln('BODY:');
      buf.write(r.body);
    }
    return buf.toString();
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

