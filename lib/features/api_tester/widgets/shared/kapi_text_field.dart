// kapi_text_field.dart
// Purpose: Reusable styled text field using the Kapi dark theme.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

class KapiTextField extends StatelessWidget {
  const KapiTextField({
    super.key,
    required this.controller,
    this.hint,
    this.label,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.monospace = false,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.errorText,
    this.suffixIcon,
    this.prefixIcon,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String? hint;
  final String? label;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final bool monospace;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? errorText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontFamily: monospace ? 'monospace' : null,
      fontSize: 12,
      color: AppColors.inputText,
      height: 1.5,
    );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      style: textStyle,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        errorText: errorText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        isDense: true,
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.inputBorder),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.inputBorder),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.inputBorderFocus, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        hintStyle: const TextStyle(color: AppColors.inputHint, fontSize: 12),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 11),
      ),
    );
  }
}
