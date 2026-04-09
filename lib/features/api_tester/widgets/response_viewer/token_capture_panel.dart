// token_capture_panel.dart
// Purpose: Shown in the response area after a successful Token Endpoint request.
//          Displays captured token with masked value, copy action, expiry info,
//          and a CTA to switch to Protected Endpoint mode.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/endpoint_type.dart';
import '../../state/api_tester_notifier.dart';
import '../shared/copy_button.dart';

class TokenCapturePanel extends StatefulWidget {
  const TokenCapturePanel({super.key});

  @override
  State<TokenCapturePanel> createState() => _TokenCapturePanelState();
}

class _TokenCapturePanelState extends State<TokenCapturePanel> {
  bool _showFull = false;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ApiTesterNotifier>();
    final token = notifier.capturedToken;
    final extractionError = notifier.tokenExtractionError;

    // Extraction failed
    if (extractionError != null) {
      return _buildError(extractionError);
    }

    // No token (shouldn't normally appear, but guard anyway)
    if (token == null) return const SizedBox.shrink();

    // Token captured successfully
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.07),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingLg,
              AppConstants.spacingMd,
              AppConstants.spacingMd,
              AppConstants.spacingXs,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 15,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Token captured',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                // Copy raw token value
                CopyButton(
                  getText: () => token.value,
                  tooltip: 'Copy token value',
                  feedback: 'Token copied',
                  withLabel: true,
                ),
              ],
            ),
          ),

          // Token value row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingLg,
              vertical: AppConstants.spacingXs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show/hide toggle
                GestureDetector(
                  onTap: () => setState(() => _showFull = !_showFull),
                  child: Text(
                    _showFull ? 'Hide' : 'Show',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    _showFull ? token.value : token.maskedValue,
                    style: const TextStyle(
                      color: AppColors.textCode,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Metadata row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingLg,
              vertical: AppConstants.spacingXs,
            ),
            child: Wrap(
              spacing: AppConstants.spacingLg,
              children: [
                _MetaChip(label: 'Type', value: token.tokenType),
                _MetaChip(label: 'From', value: token.sourceEndpoint),
                if (token.expiresIn != null)
                  _MetaChip(
                    label: 'Expires in',
                    value: '${token.expiresIn}s',
                    warn: token.isLikelyExpired,
                  ),
                if (token.isLikelyExpired)
                  const _MetaChip(
                    label: 'Status',
                    value: 'Likely expired',
                    warn: true,
                  ),
              ],
            ),
          ),

          // CTA: switch to protected endpoint
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingLg,
              AppConstants.spacingXs,
              AppConstants.spacingLg,
              AppConstants.spacingMd,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 13,
                  color: AppColors.primaryGreenDim,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Now set Endpoint Type to ',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
                GestureDetector(
                  onTap: () {
                    context
                        .read<ApiTesterNotifier>()
                        .setEndpointType(EndpointType.protectedEndpoint);
                    // Scroll focus hint — no scroll controller needed, just the label change
                  },
                  child: const Text(
                    'Protected Endpoint',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const Text(
                  ' to auto-inject this token.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingMd,
      ),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.warningBackground,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 15, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Token extraction failed',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.value,
    this.warn = false,
  });

  final String label;
  final String value;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 10),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: warn ? AppColors.warning : AppColors.textLabel,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
