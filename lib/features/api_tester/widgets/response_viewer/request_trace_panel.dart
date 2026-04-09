// request_trace_panel.dart
// Purpose: Displays the exact request sent on the wire — URL, method, headers, body, and a Copy as cURL button.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/request_trace.dart';
import '../shared/copy_button.dart';

/// A panel showing the resolved request details (what was actually sent).
/// Collapsed by default; the user can expand it via the toggle.
class RequestTracePanel extends StatefulWidget {
  const RequestTracePanel({super.key, required this.trace});
  final RequestTrace trace;

  @override
  State<RequestTracePanel> createState() => _RequestTracePanelState();
}

class _RequestTracePanelState extends State<RequestTracePanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Toggle header ─────────────────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLg,
                vertical: AppConstants.spacingSm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.send_outlined,
                      size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  const Text(
                    'REQUEST SENT',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  // Method badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreenFaint,
                      border: Border.all(color: AppColors.primaryGreenDim),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      widget.trace.method,
                      style: const TextStyle(
                        color: AppColors.primaryGreenBright,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  // URL preview
                  Expanded(
                    child: Text(
                      widget.trace.fullUrl,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  // Copy as cURL
                  CopyButton(
                    getText: () => widget.trace.curlCommand,
                    tooltip: 'Copy as cURL',
                    feedback: 'cURL copied',
                    withLabel: true,
                  ),
                  const SizedBox(width: AppConstants.spacingXs),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable body ───────────────────────────────────────────────────
          if (_expanded) _TracePanelBody(trace: widget.trace),
        ],
      ),
    );
  }
}

class _TracePanelBody extends StatelessWidget {
  const _TracePanelBody({required this.trace});
  final RequestTrace trace;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.borderMuted)),
      ),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // URL + Method
          _TraceRow(label: 'Method', value: trace.method),
          _TraceRow(label: 'URL', value: trace.fullUrl, mono: true),
          _TraceRow(label: 'Body type', value: trace.bodyType),

          if (trace.sentHeaders.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingMd),
            const _SectionLabel('Headers Sent'),
            ...trace.sentHeaders.entries.map(
              (e) => _HeaderRow(name: e.key, value: e.value),
            ),
          ],

          if (trace.bodyText.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingMd),
            const _SectionLabel('Request Body'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(3),
              ),
              child: SelectableText(
                trace.bodyText,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: AppColors.textCode,
                  height: 1.5,
                ),
              ),
            ),
          ],

          const SizedBox(height: AppConstants.spacingMd),
          const _SectionLabel('cURL Command'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(3),
            ),
            child: SelectableText(
              trace.curlCommand,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: AppColors.textCode,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXs),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _TraceRow extends StatelessWidget {
  const _TraceRow({required this.label, required this.value, this.mono = false});
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                color: mono ? AppColors.textCode : AppColors.textSecondary,
                fontSize: 11,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.name, required this.value});
  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: SelectableText(
              name,
              style: const TextStyle(
                color: AppColors.textLabel,
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                color: AppColors.textCode,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
