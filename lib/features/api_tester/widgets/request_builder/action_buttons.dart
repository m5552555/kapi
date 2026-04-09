// action_buttons.dart
// Purpose: Send and Reset action buttons fixed at the bottom of the request panel.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/endpoint_type.dart';
import '../../state/api_tester_notifier.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ApiTesterNotifier>();
    final isLoading = notifier.isLoading;
    final endpointType = notifier.endpointType;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): () {
          if (!isLoading) context.read<ApiTesterNotifier>().sendRequest();
        },
      },
      child: Focus(
        child: Container(
          height: AppConstants.actionBarHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLg,
            vertical: AppConstants.spacingMd,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              // Send button
              Expanded(
                flex: 3,
                child: _SendButton(isLoading: isLoading, endpointType: endpointType),
              ),
              const SizedBox(width: AppConstants.spacingSm),
              // Reset button
              _ResetButton(enabled: !isLoading),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.isLoading, required this.endpointType});
  final bool isLoading;
  final EndpointType endpointType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () => context.read<ApiTesterNotifier>().sendRequest(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreenDim,
          foregroundColor: AppColors.primaryGreenBright,
          disabledBackgroundColor: AppColors.surfaceHighlight,
          disabledForegroundColor: AppColors.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Sending...',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    endpointType == EndpointType.tokenEndpoint
                        ? Icons.key_rounded
                        : endpointType == EndpointType.protectedEndpoint
                            ? Icons.lock_open_rounded
                            : Icons.send_rounded,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    endpointType == EndpointType.tokenEndpoint
                        ? 'Get Token'
                        : endpointType == EndpointType.protectedEndpoint
                            ? 'Send Protected'
                            : 'Send Request',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.enabled});
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: OutlinedButton(
        onPressed: enabled ? () => context.read<ApiTesterNotifier>().reset() : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textMuted,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: const Text(
          'Reset',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
