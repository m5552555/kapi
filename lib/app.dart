// app.dart
// Purpose: Root MaterialApp configuration with the Kapi theme and Provider setup.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/api_tester/presentation/api_tester_screen.dart';
import 'features/api_tester/state/api_tester_notifier.dart';
import 'features/api_tester/state/preset_notifier.dart';

class KapiApp extends StatelessWidget {
  const KapiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiTesterNotifier()),
        ChangeNotifierProvider(create: (_) => PresetNotifier()),
      ],
      child: MaterialApp(
        title: AppConstants.appTitle,
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: const ApiTesterScreen(),
      ),
    );
  }
}
