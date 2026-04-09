// main.dart
// Purpose: Application entry point — initializes Flutter bindings and launches the Kapi desktop app.

import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KapiApp());
}
