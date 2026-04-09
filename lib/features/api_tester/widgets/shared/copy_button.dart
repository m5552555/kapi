// copy_button.dart
// Purpose: Reusable icon button that copies a deferred text value to clipboard and shows feedback.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/copy_utils.dart';

/// An icon button that, when tapped, calls [getText] to obtain the string to copy,
/// writes it to the clipboard, and shows a brief snackbar confirmation.
/// Using a callback defers potentially expensive string-building until the tap occurs.
class CopyButton extends StatelessWidget {
  const CopyButton({
    super.key,
    required this.getText,
    this.tooltip = 'Copy',
    this.feedback = 'Copied',
    this.iconSize = 13.0,
    this.color = AppColors.textMuted,
    this.withLabel = false,
  });

  final String Function() getText;
  final String tooltip;
  final String feedback;
  final double iconSize;
  final Color color;

  /// If true, show "Copy" text alongside the icon (for prominent copy buttons).
  final bool withLabel;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => CopyUtils.copy(context, getText(), feedback: feedback),
        borderRadius: BorderRadius.circular(3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: withLabel
              ? BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(3),
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.copy_rounded, size: iconSize, color: color),
              if (withLabel) ...[
                const SizedBox(width: 4),
                Text(
                  'Copy',
                  style: TextStyle(color: color, fontSize: 10),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
