// auth_section.dart
// Purpose: Authentication configuration panel that shows only the fields relevant to the selected auth type.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/auth_config.dart';
import '../../state/api_tester_notifier.dart';
import '../shared/kapi_text_field.dart';

class AuthSection extends StatelessWidget {
  const AuthSection({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ApiTesterNotifier>();

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Auth type selector
          _AuthTypeSelector(current: notifier.authType),
          const SizedBox(height: AppConstants.spacingMd),
          // Auth-type-specific fields
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: switch (notifier.authType) {
              AuthType.none => const _NoneHint(),
              AuthType.basicAuth => const _BasicAuthFields(),
              AuthType.bearerToken => const _BearerFields(),
              AuthType.apiKey => const _ApiKeyFields(),
            },
          ),
        ],
      ),
    );
  }
}

class _AuthTypeSelector extends StatelessWidget {
  const _AuthTypeSelector({required this.current});
  final AuthType current;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppConstants.spacingSm,
      children: AuthType.values
          .map((t) => _AuthChip(type: t, selected: t == current))
          .toList(),
    );
  }
}

class _AuthChip extends StatelessWidget {
  const _AuthChip({required this.type, required this.selected});
  final AuthType type;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ApiTesterNotifier>().setAuthType(type),
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
      'No authentication will be added to this request.',
      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
    );
  }
}

class _BasicAuthFields extends StatelessWidget {
  const _BasicAuthFields();

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<ApiTesterNotifier>();
    return Column(
      children: [
        KapiTextField(
          controller: notifier.usernameController,
          hint: 'Username',
          label: 'Username',
          onChanged: (_) {},
        ),
        const SizedBox(height: AppConstants.spacingSm),
        KapiTextField(
          controller: notifier.passwordController,
          hint: 'Password',
          label: 'Password',
          onChanged: (_) {},
        ),
      ],
    );
  }
}

class _BearerFields extends StatelessWidget {
  const _BearerFields();

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<ApiTesterNotifier>();
    return Column(
      children: [
        KapiTextField(
          controller: notifier.tokenController,
          hint: 'eyJhbGciOiJIUzI1NiIs...',
          label: 'Bearer Token',
          monospace: true,
          onChanged: (_) {},
        ),
        const SizedBox(height: AppConstants.spacingXs),
        const Text(
          'Will be sent as: Authorization: Bearer <token>',
          style: TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
      ],
    );
  }
}

class _ApiKeyFields extends StatelessWidget {
  const _ApiKeyFields();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ApiTesterNotifier>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: KapiTextField(
                controller: notifier.apiKeyNameController,
                hint: 'X-Api-Key',
                label: 'Key Name',
                onChanged: (_) {},
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Expanded(
              child: KapiTextField(
                controller: notifier.apiKeyValueController,
                hint: 'your-api-key',
                label: 'Key Value',
                monospace: true,
                onChanged: (_) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSm),
        // Placement picker
        Row(
          children: [
            const Text(
              'Add to:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            ...ApiKeyPlacement.values.map(
              (p) => Padding(
                padding: const EdgeInsets.only(right: AppConstants.spacingSm),
                child: _PlacementChip(
                  placement: p,
                  selected: p == notifier.apiKeyPlacement,
                  onTap: () => context.read<ApiTesterNotifier>().setApiKeyPlacement(p),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlacementChip extends StatelessWidget {
  const _PlacementChip({
    required this.placement,
    required this.selected,
    required this.onTap,
  });

  final ApiKeyPlacement placement;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          placement.label,
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
