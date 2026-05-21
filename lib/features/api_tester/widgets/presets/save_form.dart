// save_form.dart
// Purpose: Inline form for naming a new preset before saving.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class SaveForm extends StatelessWidget {
  const SaveForm({
    super.key,
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
