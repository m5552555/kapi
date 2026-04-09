// app_constants.dart
// Purpose: Application-wide constants for sizing, timeouts, and string labels.

abstract final class AppConstants {
  // Window
  static const double minWindowWidth = 1024.0;
  static const double minWindowHeight = 680.0;

  // Layout
  static const double requestPanelWidth = 460.0;
  static const double headerHeight = 52.0;
  static const double sectionHeaderHeight = 40.0;
  static const double actionBarHeight = 56.0;
  static const double rowHeight = 36.0;

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;

  // Border radius
  static const double radiusSm = 4.0;
  static const double radiusMd = 6.0;
  static const double radiusLg = 8.0;

  // Request
  static const int requestTimeoutSeconds = 30;
  static const int maxResponseDisplayBytes = 5 * 1024 * 1024; // 5 MB

  // App identity
  static const String appTitle = 'khallaf Api test';
  static const String appProduct = 'Kapi';
  static const String appVersion = '1.0.0';

  // Placeholders
  static const String baseUrlHint = 'https://api.example.com';
  static const String endpointHint = '/v1/resource';
}
