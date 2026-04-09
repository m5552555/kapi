// request_state.dart
// Purpose: Sealed class representing the lifecycle states of an API request.

import 'api_response.dart';
import 'app_error.dart';

sealed class RequestState {
  const RequestState();
}

/// No request has been sent yet, or it was cleared.
final class IdleState extends RequestState {
  const IdleState();
}

/// A request is currently in progress.
final class LoadingState extends RequestState {
  const LoadingState();
}

/// The request completed and a response was received (any HTTP status).
final class SuccessState extends RequestState {
  const SuccessState(this.response);
  final ApiResponse response;
}

/// The request failed before a response could be received (network, timeout, etc.).
final class FailureState extends RequestState {
  const FailureState(this.error);
  final AppError error;
}

/// The request form has validation errors and cannot be sent.
final class ValidationErrorState extends RequestState {
  const ValidationErrorState(this.message);
  final String message;
}
