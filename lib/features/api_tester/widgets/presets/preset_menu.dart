// preset_menu.dart
// Purpose: Header button that opens the presets management dialog.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../state/api_tester_notifier.dart';
import '../../state/preset_notifier.dart';
import 'presets_dialog.dart';

/// A compact header button that opens the presets management dialog.
class PresetMenuButton extends StatelessWidget {
  const PresetMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final hasPresets = context.watch<PresetNotifier>().hasPresets;

    return Tooltip(
      message: 'Presets — save & reuse request configurations',
      child: InkWell(
        onTap: () => _showPresetsDialog(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: hasPresets
                ? AppColors.primaryGreenFaint
                : AppColors.surfaceHighlight,
            border: Border.all(
              color: hasPresets ? AppColors.primaryGreenDim : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
          child: Row(
            children: [
              Icon(
                Icons.bookmark_border_rounded,
                size: 13,
                color: hasPresets
                    ? AppColors.primaryGreen
                    : AppColors.textMuted,
              ),
              const SizedBox(width: 5),
              Text(
                'Presets',
                style: TextStyle(
                  color: hasPresets
                      ? AppColors.primaryGreen
                      : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPresetsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => ChangeNotifierProvider.value(
        value: context.read<PresetNotifier>(),
        child: PresetsDialog(
          apiNotifier: context.read<ApiTesterNotifier>(),
        ),
      ),
    );
  }
}
