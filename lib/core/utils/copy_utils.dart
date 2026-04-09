// copy_utils.dart
// Purpose: Centralized clipboard utility — copies text and shows a brief floating feedback snackbar.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

abstract final class CopyUtils {
  /// Copies [text] to the system clipboard and shows a brief non-blocking snackbar.
  /// Safe to call from any widget tree that has a Scaffold ancestor.
  static Future<void> copy(
    BuildContext context,
    String text, {
    String feedback = 'Copied',
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            feedback,
            style: const TextStyle(
              color: AppColors.primaryGreenBright,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          duration: const Duration(milliseconds: 1400),
          backgroundColor: AppColors.surfaceRaised,
          behavior: SnackBarBehavior.floating,
          width: 180,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: AppColors.border),
          ),
          elevation: 6,
        ),
      );
  }
}
