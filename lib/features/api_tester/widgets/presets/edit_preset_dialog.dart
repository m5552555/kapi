// edit_preset_dialog.dart
// Purpose: AlertDialog letting the user rename a saved preset and overwrite it
//          with the current request form state.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class EditPresetDialog extends StatefulWidget {
  const EditPresetDialog({
    super.key,
    required this.initialName,
    required this.onUpdate,
  });

  final String initialName;
  final void Function(String newName) onUpdate;

  @override
  State<EditPresetDialog> createState() => _EditPresetDialogState();
}

class _EditPresetDialogState extends State<EditPresetDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: const BorderSide(color: AppColors.border),
      ),
      title: const Text(
        'Edit Preset',
        style: TextStyle(
          color: AppColors.primaryGreen,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ),
        TextButton(
          onPressed: () => widget.onUpdate(_ctrl.text),
          child: const Text(
            'Update',
            style: TextStyle(
              color: AppColors.primaryGreenBright,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
