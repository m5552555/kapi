// error_panel.dart
// Purpose: Structured error display panel showing technical detail, human explanation, cause, and next step.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/app_error.dart';
import '../shared/copy_button.dart';

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({super.key, required this.error, this.compact = false});
  final AppError error;
  final bool compact;

  static IconData _categoryIcon(ErrorCategory cat) => switch (cat) {
        ErrorCategory.network => Icons.wifi_off_rounded,
        ErrorCategory.timeout => Icons.timer_off_rounded,
        ErrorCategory.tls => Icons.lock_open_rounded,
        ErrorCategory.auth => Icons.lock_person_rounded,
        ErrorCategory.notFound => Icons.search_off_rounded,
        ErrorCategory.serverError => Icons.dns_rounded,
        ErrorCategory.clientError => Icons.error_outline_rounded,
        ErrorCategory.parsing => Icons.code_off_rounded,
        ErrorCategory.validation => Icons.rule_rounded,
        ErrorCategory.unknown => Icons.help_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.errorBackground,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Error header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingLg,
              vertical: AppConstants.spacingMd,
            ),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusMd),
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.error.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _categoryIcon(error.category),
                  size: 16,
                  color: AppColors.error,
                ),
                const SizedBox(width: AppConstants.spacingSm),
                Expanded(
                  child: Text(
                    error.technical,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                CopyButton(
                  getText: _errorText,
                  tooltip: 'Copy error details',
                  feedback: 'Error copied',
                ),
              ],
            ),
          ),

          // Error details
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ErrorRow(
                  icon: Icons.info_outline,
                  label: 'What happened',
                  value: error.meaning,
                  color: AppColors.error.withValues(alpha: 0.8),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                _ErrorRow(
                  icon: Icons.search_rounded,
                  label: 'Likely cause',
                  value: error.likelyCause,
                  color: AppColors.warning,
                ),
                const SizedBox(height: AppConstants.spacingMd),
                _ErrorRow(
                  icon: Icons.arrow_forward_rounded,
                  label: 'Try next',
                  value: error.nextStep,
                  color: AppColors.primaryGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _errorText() {
    return [
      'Technical: ${error.technical}',
      'Meaning: ${error.meaning}',
      'Likely cause: ${error.likelyCause}',
      'Try next: ${error.nextStep}',
    ].join('\n');
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Compact inline error for HTTP 4xx/5xx shown alongside the response body.
class InlineStatusError extends StatelessWidget {
  const InlineStatusError({super.key, required this.error});
  final AppError error;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.spacingLg,
        AppConstants.spacingMd,
        AppConstants.spacingLg,
        0,
      ),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.warningBackground,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 13, color: AppColors.warning),
              const SizedBox(width: 6),
              Text(
                error.technical,
                style: const TextStyle(
                  color: AppColors.warning,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            error.meaning,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            'Try: ${error.nextStep}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
