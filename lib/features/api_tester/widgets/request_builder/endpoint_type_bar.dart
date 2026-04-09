// endpoint_type_bar.dart
// Purpose: Compact endpoint-type selector (Normal / Token Endpoint / Protected Endpoint)
//          and token status indicator shown between the URL row and the auth section.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/endpoint_type.dart';
import '../../state/api_tester_notifier.dart';

class EndpointTypeBar extends StatelessWidget {
  const EndpointTypeBar({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ApiTesterNotifier>();
    final selected = notifier.endpointType;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingMd,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Type chips
          Row(
            children: EndpointType.values.map((type) {
              final isSelected = type == selected;
              return Padding(
                padding: const EdgeInsets.only(right: AppConstants.spacingSm),
                child: _TypeChip(
                  type: type,
                  isSelected: isSelected,
                  onTap: () => context.read<ApiTesterNotifier>().setEndpointType(type),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppConstants.spacingXs),

          // Hint text
          Text(
            selected.hint,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              height: 1.4,
            ),
          ),

          // Token status row (only when relevant)
          if (selected != EndpointType.normal) ...[
            const SizedBox(height: AppConstants.spacingXs),
            _TokenStatusRow(notifier: notifier, endpointType: selected),
          ],
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final EndpointType type;
  final bool isSelected;
  final VoidCallback onTap;

  Color get _accentColor => switch (type) {
        EndpointType.normal => AppColors.textMuted,
        EndpointType.tokenEndpoint => AppColors.info,
        EndpointType.protectedEndpoint => AppColors.primaryGreen,
      };

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.15)
              : AppColors.background,
          border: Border.all(
            color: isSelected ? accent : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        child: Text(
          type.label,
          style: TextStyle(
            color: isSelected ? accent : AppColors.textMuted,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TokenStatusRow extends StatelessWidget {
  const _TokenStatusRow({
    required this.notifier,
    required this.endpointType,
  });

  final ApiTesterNotifier notifier;
  final EndpointType endpointType;

  @override
  Widget build(BuildContext context) {
    final hasToken = notifier.hasToken;
    final token = notifier.capturedToken;

    if (!hasToken) {
      // No token captured yet
      return Row(
        children: [
          Icon(
            Icons.radio_button_unchecked,
            size: 12,
            color: AppColors.warning.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'No token captured yet — run a Token Endpoint request first.',
              style: TextStyle(color: AppColors.warning, fontSize: 10),
            ),
          ),
        ],
      );
    }

    // Token available
    final expiredWarning = token!.isLikelyExpired;

    return Row(
      children: [
        Icon(
          expiredWarning ? Icons.warning_amber_rounded : Icons.check_circle_outline,
          size: 12,
          color: expiredWarning ? AppColors.warning : AppColors.primaryGreen,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            expiredWarning
                ? 'Token may have expired — ${token.maskedValue}'
                : 'Token ready: ${token.maskedValue}  (from ${token.sourceEndpoint})',
            style: TextStyle(
              color: expiredWarning ? AppColors.warning : AppColors.primaryGreen,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        // Clear token button
        GestureDetector(
          onTap: () => context.read<ApiTesterNotifier>().clearCapturedToken(),
          child: const Text(
            'Clear',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
