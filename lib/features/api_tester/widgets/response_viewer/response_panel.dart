// response_panel.dart
// Purpose: Main response viewer container — switches between idle, loading, success, and failure states.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/error_interpreter.dart';
import '../../domain/models/api_response.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/request_state.dart';
import '../../state/api_tester_notifier.dart';
import '../shared/copy_button.dart';
import 'error_panel.dart';
import 'export_section.dart';
import 'request_trace_panel.dart';
import 'response_body_view.dart';
import 'status_bar.dart';
import 'token_capture_panel.dart';

class ResponsePanel extends StatelessWidget {
  const ResponsePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ApiTesterNotifier>();
    final state = notifier.requestState;
    final showTokenPanel = notifier.lastSendWasTokenEndpoint &&
        (state is SuccessState || notifier.tokenExtractionError != null);

    return switch (state) {
      IdleState() => const _IdlePlaceholder(),
      LoadingState() => const _LoadingIndicator(),
      ValidationErrorState(:final message) => _ValidationError(message: message),
      SuccessState(:final response) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _ResponseView(
                response: response,
                showTokenPanel: showTokenPanel,
              ),
            ),
            const ExportSection(),
          ],
        ),
      FailureState(:final error) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _FailureView(error: error)),
            const ExportSection(),
          ],
        ),
    };
  }
}

class _IdlePlaceholder extends StatelessWidget {
  const _IdlePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.send_rounded,
            size: 48,
            color: AppColors.textMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppConstants.spacingLg),
          const Text(
            'Send a request to see the response here',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXs),
          const Text(
            'Configure the method, URL, and parameters on the left,\nthen click Send Request or press Ctrl+Enter.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryGreenDim,
            ),
          ),
          SizedBox(height: AppConstants.spacingLg),
          Text(
            'Sending request...',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ValidationError extends StatelessWidget {
  const _ValidationError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppConstants.spacingXl),
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        decoration: BoxDecoration(
          color: AppColors.warningBackground,
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warning),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cannot send request',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponseView extends StatelessWidget {
  const _ResponseView({required this.response, required this.showTokenPanel});
  final ApiResponse response;
  final bool showTokenPanel;

  @override
  Widget build(BuildContext context) {
    final trace = context.watch<ApiTesterNotifier>().lastTrace;
    final showInlineError = response.isClientError || response.isServerError;
    final inlineError = showInlineError
        ? ErrorInterpreter.fromStatusCode(response.statusCode)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status summary bar
        StatusBar(response: response),

        // Token capture result (only after Token Endpoint sends)
        if (showTokenPanel) const TokenCapturePanel(),

        // Collapsible request trace (what was sent)
        if (trace != null) RequestTracePanel(trace: trace),

        // Inline error interpretation for 4xx/5xx
        if (inlineError != null) InlineStatusError(error: inlineError),

        // Tabbed body / headers
        Expanded(
          child: _ResponseTabs(response: response),
        ),
      ],
    );
  }
}

class _ResponseTabs extends StatefulWidget {
  const _ResponseTabs({required this.response});
  final ApiResponse response;

  @override
  State<_ResponseTabs> createState() => _ResponseTabsState();
}

class _ResponseTabsState extends State<_ResponseTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: TabBar(
            controller: _tab,
            isScrollable: false,
            indicatorColor: AppColors.primaryGreen,
            indicatorWeight: 2,
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'BODY'),
              Tab(text: 'HEADERS'),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              ResponseBodyView(response: widget.response),
              _ResponseHeadersView(headers: widget.response.headers),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResponseHeadersView extends StatelessWidget {
  const _ResponseHeadersView({required this.headers});
  final Map<String, String> headers;

  String _headersText() {
    final sorted = headers.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return sorted.map((e) => '${e.key}: ${e.value}').join('\n');
  }

  @override
  Widget build(BuildContext context) {
    if (headers.isEmpty) {
      return const Center(
        child: Text(
          'No response headers',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      );
    }

    final sorted = headers.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toolbar
        Container(
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
              Text(
                '${headers.length} header${headers.length == 1 ? '' : 's'}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
              ),
              const Spacer(),
              CopyButton(
                getText: _headersText,
                tooltip: 'Copy all headers',
                feedback: 'Headers copied',
                withLabel: true,
              ),
            ],
          ),
        ),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
              itemCount: sorted.length,
              separatorBuilder: (context, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = sorted[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingLg,
                    vertical: AppConstants.spacingXs,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 200,
                        child: SelectableText(
                          entry.key,
                          style: const TextStyle(
                            color: AppColors.textLabel,
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: SelectableText(
                          entry.value,
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
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.error});
  final AppError error;

  @override
  Widget build(BuildContext context) {
    final trace = context.watch<ApiTesterNotifier>().lastTrace;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ErrorPanel(error: error),

          // Show what was sent even on failure — helps diagnose connection issues
          if (trace != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacingLg,
                0,
                AppConstants.spacingLg,
                AppConstants.spacingMd,
              ),
              child: RequestTracePanel(trace: trace),
            ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingLg,
            ),
            child: Text(
              'Failed at ${DateTime.now().toLocal().toString().substring(0, 19)}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
