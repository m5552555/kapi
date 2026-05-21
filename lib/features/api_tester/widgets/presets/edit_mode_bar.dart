// edit_mode_bar.dart
// Purpose: Top banner shown while the user is editing an existing preset —
//          offers Cancel (exit edit mode) and Update preset (overwrite & stay).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../state/api_tester_notifier.dart';
import '../../state/preset_notifier.dart';

class EditModeBar extends StatelessWidget {
  const EditModeBar({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ApiTesterNotifier>();
    if (!notifier.isEditingPreset) return const SizedBox.shrink();

    final name = notifier.editingPresetName ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreenFaint,
        border: Border(
          bottom: BorderSide(color: AppColors.primaryGreenDim),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.edit_outlined,
            size: 14,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EDITING:',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primaryGreenBright,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          _CancelButton(onTap: notifier.exitEditMode),
          const SizedBox(width: AppConstants.spacingXs),
          _UpdateButton(
            onTap: () => _onUpdate(context, notifier),
          ),
        ],
      ),
    );
  }

  void _onUpdate(BuildContext context, ApiTesterNotifier notifier) {
    final id = notifier.editingPresetId;
    final name = notifier.editingPresetName;
    if (id == null || name == null) return;

    final messenger = ScaffoldMessenger.of(context);
    context.read<PresetNotifier>().overwritePreset(id, name, notifier);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            'Preset updated.',
            style: TextStyle(
              color: AppColors.primaryGreenBright,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          duration: const Duration(milliseconds: 2000),
          backgroundColor: AppColors.surfaceRaised,
          behavior: SnackBarBehavior.floating,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            side: const BorderSide(color: AppColors.border),
          ),
          elevation: 6,
        ),
      );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _UpdateButton extends StatelessWidget {
  const _UpdateButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryGreenDim,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        child: const Text(
          'Update preset',
          style: TextStyle(
            color: AppColors.primaryGreenBright,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
