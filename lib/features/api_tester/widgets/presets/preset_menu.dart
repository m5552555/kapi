// preset_menu.dart
// Purpose: Presets button and dialog for saving, viewing, applying, and deleting named request presets.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../state/api_tester_notifier.dart';
import '../../state/preset_notifier.dart';

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
        child: Builder(
          builder: (innerCtx) => _PresetsDialog(
            apiNotifier: context.read<ApiTesterNotifier>(),
          ),
        ),
      ),
    );
  }
}

class _PresetsDialog extends StatefulWidget {
  const _PresetsDialog({required this.apiNotifier});
  final ApiTesterNotifier apiNotifier;

  @override
  State<_PresetsDialog> createState() => _PresetsDialogState();
}

class _PresetsDialogState extends State<_PresetsDialog> {
  final _nameCtrl = TextEditingController();
  bool _showSaveForm = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
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
            // ── Header ──────────────────────────────────────────────────
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

            // ── Preset list ──────────────────────────────────────────────
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
                  itemBuilder: (ctx, i) => _PresetRow(
                    preset: presets[i],
                    onApply: () {
                      context.read<PresetNotifier>().apply(presets[i], widget.apiNotifier);
                      Navigator.of(context).pop();
                    },
                    onDelete: () =>
                        context.read<PresetNotifier>().delete(presets[i].id),
                  ),
                ),
              ),

            // ── Save form ────────────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: _showSaveForm
                  ? _SaveForm(
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

class _PresetRow extends StatelessWidget {
  const _PresetRow({
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
          // Apply button
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
          // Delete button
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

class _SaveForm extends StatelessWidget {
  const _SaveForm({
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            onSubmitted: (_) => onSave(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
            decoration: const InputDecoration(
              hintText: 'Preset name…',
              isDense: true,
              filled: true,
              fillColor: AppColors.inputBackground,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.inputBorder),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.inputBorder),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.inputBorderFocus, width: 1.5),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              hintStyle: TextStyle(color: AppColors.inputHint, fontSize: 11),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        InkWell(
          onTap: onSave,
          borderRadius: BorderRadius.circular(3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primaryGreenDim,
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.primaryGreenBright,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingXs),
        InkWell(
          onTap: onCancel,
          borderRadius: BorderRadius.circular(3),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.close, size: 13, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
