// preset_row.dart
// Purpose: A single preset list row with Apply, Edit, and Delete actions.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../state/api_tester_notifier.dart';
import '../../state/preset_notifier.dart';
import 'edit_preset_dialog.dart';

class PresetRow extends StatelessWidget {
  const PresetRow({
    super.key,
    required this.preset,
    required this.apiNotifier,
    required this.onApply,
    required this.onDelete,
  });

  final dynamic preset;
  final ApiTesterNotifier apiNotifier;
  final VoidCallback onApply;
  final VoidCallback onDelete;

  void _showEditDialog(BuildContext context) {
    final notifier = context.read<PresetNotifier>();
    final messenger = ScaffoldMessenger.of(context);

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => EditPresetDialog(
        initialName: preset.name as String,
        onUpdate: (newName) {
          notifier.overwritePreset(
            preset.id as String,
            newName,
            apiNotifier,
          );
          Navigator.of(ctx).pop();
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
                  borderRadius: BorderRadius.circular(6),
                  side: const BorderSide(color: AppColors.border),
                ),
                elevation: 6,
              ),
            );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingXs,
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark, size: 12, color: AppColors.primaryGreenDim),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preset.name as String,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if ((preset.baseUrl as String).isNotEmpty)
                  Text(
                    preset.baseUrl as String,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          InkWell(
            onTap: onApply,
            borderRadius: BorderRadius.circular(3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreenFaint,
                border: Border.all(color: AppColors.primaryGreenDim),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  color: AppColors.primaryGreenBright,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingXs),
          Tooltip(
            message: 'Edit preset',
            child: InkWell(
              onTap: () => _showEditDialog(context),
              borderRadius: BorderRadius.circular(3),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.edit_outlined,
                    size: 14, color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingXs),
          Tooltip(
            message: 'Delete preset',
            child: InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(3),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.delete_outline_rounded,
                    size: 14, color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
