// method_selector.dart
// Purpose: HTTP method dropdown selector with color-coded method labels.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/api_request.dart';
import '../../state/api_tester_notifier.dart';

class MethodSelector extends StatelessWidget {
  const MethodSelector({super.key});

  static Color _methodColor(HttpMethod method) => switch (method) {
        HttpMethod.get => AppColors.methodGet,
        HttpMethod.post => AppColors.methodPost,
        HttpMethod.put => AppColors.methodPut,
        HttpMethod.patch => AppColors.methodPatch,
        HttpMethod.delete => AppColors.methodDelete,
        HttpMethod.head => AppColors.methodHead,
        HttpMethod.options => AppColors.methodOptions,
      };

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ApiTesterNotifier>();
    final current = notifier.method;
    final color = _methodColor(current);

    return PopupMenuButton<HttpMethod>(
      initialValue: current,
      onSelected: (m) => context.read<ApiTesterNotifier>().setMethod(m),
      color: AppColors.surfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppColors.border),
      ),
      itemBuilder: (_) => HttpMethod.values
          .map(
            (m) => PopupMenuItem<HttpMethod>(
              value: m,
              height: 36,
              child: Text(
                m.label,
                style: TextStyle(
                  color: _methodColor(m),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          border: Border.all(color: AppColors.inputBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              current.label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
