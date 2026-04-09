// app_colors.dart
// Purpose: Central color palette for the Kapi dark desktop theme.

import 'package:flutter/material.dart';

abstract final class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF080808);
  static const Color surface = Color(0xFF0F0F0F);
  static const Color surfaceRaised = Color(0xFF181818);
  static const Color surfaceHighlight = Color(0xFF1E1E1E);

  // Borders
  static const Color border = Color(0xFF1E2E1E);
  static const Color borderMuted = Color(0xFF151E15);
  static const Color borderFocus = Color(0xFF2E7D32);

  // Primary green accent family
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryGreenBright = Color(0xFF69F0AE);
  static const Color primaryGreenDim = Color(0xFF388E3C);
  static const Color primaryGreenFaint = Color(0xFF1B2E1B);

  // Text — improved for readability and contrast
  static const Color textPrimary = Color(0xFFE2F0E2);   // slightly brighter white-green
  static const Color textSecondary = Color(0xFF8BC88E); // clearer secondary green
  static const Color textMuted = Color(0xFF5A7A5A);     // more visible muted tone
  static const Color textLabel = Color(0xFF00E676);     // brighter label green
  static const Color textCode = Color(0xFFC8EEC8);      // clearer code green

  // Semantic states
  static const Color success = Color(0xFF4CAF50);
  static const Color successBackground = Color(0xFF0D1F0D);
  static const Color warning = Color(0xFFFF8F00);
  static const Color warningBackground = Color(0xFF1F160A);
  static const Color error = Color(0xFFEF5350);
  static const Color errorBackground = Color(0xFF1F0D0D);
  static const Color info = Color(0xFF42A5F5);
  static const Color infoBackground = Color(0xFF0D1520);

  // HTTP method colors
  static const Color methodGet = Color(0xFF69F0AE);
  static const Color methodPost = Color(0xFFFFB74D);
  static const Color methodPut = Color(0xFF42A5F5);
  static const Color methodPatch = Color(0xFFCE93D8);
  static const Color methodDelete = Color(0xFFEF5350);
  static const Color methodHead = Color(0xFF4DD0E1);
  static const Color methodOptions = Color(0xFFA5D6A7);

  // HTTP status range colors
  static const Color status2xx = Color(0xFF4CAF50);
  static const Color status3xx = Color(0xFF42A5F5);
  static const Color status4xx = Color(0xFFFF8F00);
  static const Color status5xx = Color(0xFFEF5350);

  // Input fields
  static const Color inputBackground = Color(0xFF0C0C0C);
  static const Color inputBorder = Color(0xFF1E2E1E);
  static const Color inputBorderFocus = Color(0xFF388E3C);
  static const Color inputText = Color(0xFFE2F0E2);
  static const Color inputHint = Color(0xFF3A4E3A);

  // Divider
  static const Color divider = Color(0xFF131F13);

  // Scrollbar
  static const Color scrollbar = Color(0xFF2E3E2E);

  // Selection (for multi-select rows)
  static const Color selectionBackground = Color(0xFF1A2E1A);
  static const Color selectionBorder = Color(0xFF2E5A2E);
}
