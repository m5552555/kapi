// presets_dialog.dart
// Purpose: The main presets management dialog — lists saved presets and the save form.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../state/api_tester_notifier.dart';
import '../../state/preset_notifier.dart';
import 'preset_row.dart';
import 'save_form.dart';

class PresetsDialog extends StatefulWidget {
  const PresetsDialog({super.key, required this.apiNotifier});
  final ApiTesterNotifier apiNotifier;

  @override
  State<PresetsDialog> createState() => _PresetsDialogState();
}

class _PresetsDialogState extends State<PresetsDialog> {
  final _nameCtrl = TextEditingController();
  bool _showSaveForm = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _onApply(BuildContext context, dynamic preset) {
    final messenger = ScaffoldMessenger.of(context);
    context.read<PresetNotifier>().apply(preset, widget.apiNotifier);
    Navigator.of(context).pop();
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            'Saved API loaded successfully.',
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
  }

  @override
  Widget build(BuildContext context) {
    final presetNotifier = context.watch<PresetNotifier>();
    final presets = presetNotifier.presets;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 360, maxWidth: 440, maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLg,
                vertical: AppConstants.spacingMd,
              ),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bookmark_border_rounded,
                      size: 15, color: AppColors.primaryGreen),
                  const SizedBox(width: AppConstants.spacingSm),
                  const Text(
                    'Presets',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 15, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            if (presets.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppConstants.spacingXl),
                child: Center(
                  child: Text(
                    'No presets saved yet.\nSave the current configuration below.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXs),
                  itemCount: presets.length,
                  separatorBuilder: (context, i) => const Divider(height: 1),
                  itemBuilder: (ctx, i) => PresetRow(
                    preset: presets[i],
                    apiNotifier: widget.apiNotifier,
                    onApply: () => _onApply(context, presets[i]),
                    onDelete: () =>
                        context.read<PresetNotifier>().delete(presets[i].id),
                  ),
                ),
              ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: _showSaveForm
                  ? SaveForm(
                      controller: _nameCtrl,
                      onSave: () {
                        context.read<PresetNotifier>().saveFromNotifier(
                              _nameCtrl.text,
                              widget.apiNotifier,
                            );
                        _nameCtrl.clear();
                        setState(() => _showSaveForm = false);
                      },
                      onCancel: () {
                        _nameCtrl.clear();
                        setState(() => _showSaveForm = false);
                      },
                    )
                  : TextButton.icon(
                      onPressed: () => setState(() => _showSaveForm = true),
                      icon: const Icon(Icons.add, size: 14,
                          color: AppColors.primaryGreenDim),
                      label: const Text(
                        'Save current config as preset',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        alignment: Alignment.centerLeft,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
