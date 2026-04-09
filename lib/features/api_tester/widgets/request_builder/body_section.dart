// body_section.dart
// Purpose: Request body editor with type selector, raw JSON editor with validation, and form fields support.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/api_request.dart';
import '../../state/api_tester_notifier.dart';
import '../shared/kapi_text_field.dart';
import 'kv_table.dart';

class BodySection extends StatelessWidget {
  const BodySection({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ApiTesterNotifier>();

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Body type selector
          _BodyTypeSelector(current: notifier.bodyType),
          const SizedBox(height: AppConstants.spacingMd),
          // Body-type-specific editor
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: switch (notifier.bodyType) {
              BodyType.none => const _NoneHint(),
              BodyType.rawJson => const _JsonEditor(),
              BodyType.formUrlEncoded => const _FormFieldsEditor(
                  label: 'Form URL Encoded fields',
                ),
              BodyType.formData => const _FormFieldsEditor(
                  label: 'Form Data fields',
                ),
            },
          ),
        ],
      ),
    );
  }
}

class _BodyTypeSelector extends StatelessWidget {
  const _BodyTypeSelector({required this.current});
  final BodyType current;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppConstants.spacingSm,
      children: BodyType.values
          .map((t) => _BodyTypeChip(type: t, selected: t == current))
          .toList(),
    );
  }
}

class _BodyTypeChip extends StatelessWidget {
  const _BodyTypeChip({required this.type, required this.selected});
  final BodyType type;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ApiTesterNotifier>().setBodyType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGreenFaint : AppColors.inputBackground,
          border: Border.all(
            color: selected ? AppColors.primaryGreenDim : AppColors.inputBorder,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        child: Text(
          type.label,
          style: TextStyle(
            color: selected ? AppColors.primaryGreenBright : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _NoneHint extends StatelessWidget {
  const _NoneHint();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'No body will be sent with this request.',
      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
    );
  }
}

class _JsonEditor extends StatelessWidget {
  const _JsonEditor();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ApiTesterNotifier>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toolbar
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _EditorButton(
              label: 'Validate',
              icon: Icons.check_circle_outline,
              onTap: notifier.validateJsonBody,
            ),
            const SizedBox(width: AppConstants.spacingSm),
            _EditorButton(
              label: 'Format',
              icon: Icons.auto_fix_high,
              onTap: notifier.formatJsonBody,
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingXs),
        // JSON text area
        KapiTextField(
          controller: notifier.rawJsonController,
          hint: '{\n  "key": "value"\n}',
          maxLines: null,
          minLines: 8,
          monospace: true,
          onChanged: (_) {},
          errorText: notifier.jsonError,
        ),
        if (notifier.jsonError != null)
          Padding(
            padding: const EdgeInsets.only(top: AppConstants.spacingXs),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.warning),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    notifier.jsonError!,
                    style: const TextStyle(color: AppColors.warning, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FormFieldsEditor extends StatelessWidget {
  const _FormFieldsEditor({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ApiTesterNotifier>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppConstants.spacingXs),
        KVTable(
          key: ValueKey('formfields_${notifier.resetKey}'),
          initial: notifier.formFields,
          onChanged: notifier.updateFormFields,
          keyHint: 'Field name',
          valueHint: 'Field value',
        ),
      ],
    );
  }
}

class _EditorButton extends StatelessWidget {
  const _EditorButton({
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
