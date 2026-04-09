// section_card.dart
// Purpose: Collapsible section container with a styled header for grouping request builder panels.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class SectionCard extends StatefulWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = true,
    this.count,
    this.trailing,
    this.onToggle,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final int? count;
  final Widget? trailing;
  final VoidCallback? onToggle;

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section header
        InkWell(
          onTap: _toggle,
          child: Container(
            height: AppConstants.sectionHeaderHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.borderMuted),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: AppConstants.spacingSm),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                if (widget.count != null && widget.count! > 0) ...[
                  const SizedBox(width: AppConstants.spacingSm),
                  _CountBadge(count: widget.count!),
                ],
                const Spacer(),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
          ),
        ),

        // Collapsible content
        if (_expanded)
          Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: AppColors.borderMuted)),
            ),
            child: widget.child,
          ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.primaryGreenFaint,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryGreenDim, width: 0.5),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: AppColors.primaryGreen,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
