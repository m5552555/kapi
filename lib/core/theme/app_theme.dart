// app_theme.dart
// Purpose: Defines the global dark ThemeData used throughout Kapi with improved typography hierarchy.

import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.primaryGreen,
        secondary: AppColors.primaryGreenBright,
        error: AppColors.error,
        onSurface: AppColors.textPrimary,
        onPrimary: AppColors.background,
      ),
      textTheme: _buildTextTheme(),
      inputDecorationTheme: _buildInputTheme(),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.scrollbar),
        trackColor: WidgetStateProperty.all(AppColors.surface),
        radius: const Radius.circular(4),
        thickness: WidgetStateProperty.all(6),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceHighlight,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.border),
        ),
        textStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryGreenDim;
          return AppColors.surfaceHighlight;
        }),
        checkColor: WidgetStateProperty.all(AppColors.primaryGreenBright),
        side: const BorderSide(color: AppColors.border, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceRaised,
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      useMaterial3: true,
    );
  }

  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // Bumped body sizes for better desktop readability
      bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5),
      bodyMedium: TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.5),
      bodySmall: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
      labelLarge: TextStyle(
        color: AppColors.textLabel,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
        letterSpacing: 0.4,
      ),
      headlineSmall: TextStyle(
        color: AppColors.primaryGreen,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      titleMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static InputDecorationTheme _buildInputTheme() {
    const border = OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.inputBorder),
      borderRadius: BorderRadius.all(Radius.circular(4)),
    );
    const focusBorder = OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.inputBorderFocus, width: 1.5),
      borderRadius: BorderRadius.all(Radius.circular(4)),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      border: border,
      enabledBorder: border,
      focusedBorder: focusBorder,
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.error),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      hintStyle: const TextStyle(color: AppColors.inputHint, fontSize: 12),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      isDense: true,
    );
  }
}
