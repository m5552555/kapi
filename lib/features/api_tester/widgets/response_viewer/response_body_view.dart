// response_body_view.dart
// Purpose: Displays the response body with JSON pretty-printing, copy support, and fallback for non-JSON content.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/api_response.dart';
import '../shared/copy_button.dart';

class ResponseBodyView extends StatefulWidget {
  const ResponseBodyView({super.key, required this.response});
  final ApiResponse response;

  @override
  State<ResponseBodyView> createState() => _ResponseBodyViewState();
}

class _ResponseBodyViewState extends State<ResponseBodyView> {
  bool _showRaw = false;

  String get _displayBody => _showRaw ? widget.response.rawBody : widget.response.body;

  @override
  Widget build(BuildContext context) {
    final response = widget.response;

    if (response.isEmpty) {
      return const _EmptyBodyMessage();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toolbar
        _BodyToolbar(
          isJson: response.isJson,
          showRaw: _showRaw,
          onToggleRaw: () => setState(() => _showRaw = !_showRaw),
          body: _displayBody,
          sizeBytes: response.sizeBytes,
        ),

        // Body content
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: SelectableText(
                _displayBody,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: AppColors.textCode,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BodyToolbar extends StatelessWidget {
  const _BodyToolbar({
    required this.isJson,
    required this.showRaw,
    required this.onToggleRaw,
    required this.body,
    required this.sizeBytes,
  });

  final bool isJson;
  final bool showRaw;
  final VoidCallback onToggleRaw;
  final String body;
  final int sizeBytes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingXs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderMuted)),
      ),
      child: Row(
        children: [
          // Body type label
          if (isJson)
            _LabelChip(label: showRaw ? 'Raw' : 'JSON', color: AppColors.primaryGreen)
          else
            const _LabelChip(label: 'Text', color: AppColors.info),

          const Spacer(),

          // Toggle raw
          if (isJson)
            _ToolbarButton(
              label: showRaw ? 'Show Formatted' : 'Show Raw',
              icon: showRaw ? Icons.code : Icons.text_snippet_outlined,
              onTap: onToggleRaw,
            ),
          const SizedBox(width: AppConstants.spacingSm),
          // Copy body
          CopyButton(
            getText: () => body,
            tooltip: 'Copy body',
            feedback: 'Body copied',
            withLabel: true,
          ),
        ],
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: [
            Icon(icon, size: 11, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBodyMessage extends StatelessWidget {
  const _EmptyBodyMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 32, color: AppColors.textMuted),
          const SizedBox(height: AppConstants.spacingMd),
          const Text(
            'No response body',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXs),
          const Text(
            'The server returned an empty body (e.g., 204 No Content).',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
