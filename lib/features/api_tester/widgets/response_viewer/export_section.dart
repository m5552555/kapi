// export_section.dart
// Purpose: Notes input and Export button shown at the bottom of the response panel when a result is available.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/report_exporter.dart';
import '../../state/api_tester_notifier.dart';

/// Persistent notes field + Export button rendered below the response result.
/// Manages its own notes [TextEditingController] (the notes are transient and
/// intentionally not persisted to the draft — they are per-test observations).
class ExportSection extends StatefulWidget {
  const ExportSection({super.key});

  @override
  State<ExportSection> createState() => _ExportSectionState();
}

class _ExportSectionState extends State<ExportSection> {
  final _notesCtrl = TextEditingController();
  bool _exporting = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    final notifier = context.read<ApiTesterNotifier>();

    setState(() => _exporting = true);

    final path = await ReportExporter.export(
      trace: notifier.lastTrace,
      state: notifier.requestState,
      notes: _notesCtrl.text,
      endpoint: notifier.endpointController.text.trim(),
      baseUrl: notifier.baseUrlController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _exporting = false);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            path != null
                ? 'Report saved: $path'
                : 'Export failed — check permissions for Documents\\Kapi Reports.',
            style: TextStyle(
              color: path != null
                  ? AppColors.primaryGreenBright
                  : AppColors.error,
              fontSize: 11,
            ),
          ),
          duration: Duration(seconds: path != null ? 5 : 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingLg,
        AppConstants.spacingSm,
        AppConstants.spacingLg,
        AppConstants.spacingMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Notes label + field
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'NOTES',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  minLines: 1,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Optional tester observations for the report…',
                    hintStyle: TextStyle(color: AppColors.inputHint, fontSize: 11),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.inputBorder),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.inputBorder),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: AppColors.inputBorderFocus, width: 1.5),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          // Export button
          _exporting
              ? const SizedBox(
                  width: 72,
                  height: 34,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryGreenDim,
                      ),
                    ),
                  ),
                )
              : InkWell(
                  onTap: _export,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreenDim,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Export',
                      style: TextStyle(
                        color: AppColors.primaryGreenBright,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
