// api_tester_screen.dart
// Purpose: The single main screen composing the request builder panel and response viewer panel side by side.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../state/api_tester_notifier.dart';
import '../widgets/app_header.dart';
import '../widgets/request_builder/action_buttons.dart';
import '../widgets/request_builder/auth_section.dart';
import '../widgets/request_builder/endpoint_type_bar.dart';
import '../widgets/request_builder/body_section.dart';
import '../widgets/request_builder/kv_table.dart';
import '../widgets/request_builder/url_input_row.dart';
import '../widgets/response_viewer/response_panel.dart';
import '../widgets/shared/section_card.dart';

class ApiTesterScreen extends StatelessWidget {
  const ApiTesterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixed top header
          AppHeader(),
          // Main content
          Expanded(
            child: _MainLayout(),
          ),
        ],
      ),
    );
  }
}

class _MainLayout extends StatelessWidget {
  const _MainLayout();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Request panel has a fixed width; response takes the rest.
        const panelWidth = AppConstants.requestPanelWidth;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left: request builder
            SizedBox(
              width: panelWidth,
              child: const _RequestPanel(),
            ),

            // Vertical divider
            const VerticalDivider(
              width: 1,
              color: AppColors.border,
            ),

            // Right: response viewer
            Expanded(
              child: const ResponsePanel(),
            ),
          ],
        );
      },
    );
  }
}

class _RequestPanel extends StatelessWidget {
  const _RequestPanel();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ApiTesterNotifier>();
    final resetKey = notifier.resetKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Method + URL (always visible, not collapsible)
        const UrlInputRow(),

        // Endpoint type selector + token status
        const EndpointTypeBar(),

        // Scrollable sections
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Authentication
                  SectionCard(
                    title: 'AUTHENTICATION',
                    initiallyExpanded: false,
                    child: const AuthSection(),
                  ),

                  // Headers
                  SectionCard(
                    title: 'HEADERS',
                    count: notifier.headers.where((h) => h.enabled && h.key.isNotEmpty).length,
                    child: KVTable(
                      key: ValueKey('headers_$resetKey'),
                      initial: notifier.headers,
                      onChanged: notifier.updateHeaders,
                      keyHint: 'Header name',
                      valueHint: 'Value',
                    ),
                  ),

                  // Query parameters
                  SectionCard(
                    title: 'QUERY PARAMETERS',
                    count: notifier.queryParams.where((q) => q.enabled && q.key.isNotEmpty).length,
                    child: KVTable(
                      key: ValueKey('query_$resetKey'),
                      initial: notifier.queryParams,
                      onChanged: notifier.updateQueryParams,
                      keyHint: 'Parameter name',
                      valueHint: 'Value',
                    ),
                  ),

                  // Path parameters (always visible for visibility)
                  SectionCard(
                    title: 'PATH PARAMETERS',
                    count: notifier.pathParams.where((p) => p.enabled && p.key.isNotEmpty).length,
                    initiallyExpanded: notifier.pathParams.isNotEmpty,
                    child: KVTable(
                      key: ValueKey('path_$resetKey'),
                      initial: notifier.pathParams,
                      onChanged: notifier.updatePathParams,
                      keyHint: 'Placeholder',
                      valueHint: 'Value',
                    ),
                  ),

                  // Body
                  SectionCard(
                    title: 'BODY',
                    initiallyExpanded: false,
                    child: const BodySection(),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Fixed action buttons at panel bottom
        const ActionButtons(),
      ],
    );
  }
}
