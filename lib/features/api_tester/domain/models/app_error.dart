// app_error.dart
// Purpose: Structured error model that provides technical detail, human meaning, likely cause, and next action.

enum ErrorCategory {
  network,
  timeout,
  tls,
  auth,
  notFound,
  serverError,
  clientError,
  parsing,
  validation,
  unknown,
}

class AppError {
  const AppError({
    required this.technical,
    required this.meaning,
    required this.likelyCause,
    required this.nextStep,
    this.category = ErrorCategory.unknown,
  });

  final String technical;
  final String meaning;
  final String likelyCause;
  final String nextStep;
  final ErrorCategory category;

  @override
  String toString() => 'AppError[$category]: $technical';
}
