// preset_row.dart
// Purpose: A single preset list row with Apply and Delete actions.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class PresetRow extends StatelessWidget {
  const PresetRow({
    super.key,
    required this.preset,
    required this.onApply,
    required this.onDelete,
  });

  final dynamic preset;
  final VoidCallback onApply;
  final VoidCallback onDelete;

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
