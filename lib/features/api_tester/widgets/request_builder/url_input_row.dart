// url_input_row.dart
// Purpose: Method selector + Base URL + Endpoint inputs, forming the primary request identity bar.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../state/api_tester_notifier.dart';
import '../shared/kapi_text_field.dart';
import 'method_selector.dart';

class UrlInputRow extends StatelessWidget {
  const UrlInputRow({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<ApiTesterNotifier>();

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): () {
          context.read<ApiTesterNotifier>().sendRequest();
        },
      },
      child: Focus(
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Method + URL row
              Row(
                children: [
                  const MethodSelector(),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: KapiTextField(
                      controller: notifier.baseUrlController,
                      hint: AppConstants.baseUrlHint,
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingSm),
              // Endpoint row
              KapiTextField(
                controller: notifier.endpointController,
                hint: AppConstants.endpointHint,
                onChanged: notifier.onEndpointChanged,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 8, right: 4),
                  child: Icon(Icons.chevron_right, size: 14, color: AppColors.textMuted),
                ),
              ),
              // Composed URL preview
              _ComposedUrlPreview(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposedUrlPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ApiTesterNotifier>();

    return AnimatedBuilder(
      animation: Listenable.merge([
        notifier.baseUrlController,
        notifier.endpointController,
      ]),
      builder: (context, _) {
        final base = notifier.baseUrlController.text.trim();
        final endpoint = notifier.endpointController.text.trim();
        if (base.isEmpty && endpoint.isEmpty) return const SizedBox.shrink();

        final composed = base.isNotEmpty || endpoint.isNotEmpty
            ? '${base.isNotEmpty ? base : ''}${endpoint.isNotEmpty && !endpoint.startsWith('/') && base.isNotEmpty ? '/' : ''}$endpoint'
            : '';

        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              const Icon(Icons.link, size: 11, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  composed,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
