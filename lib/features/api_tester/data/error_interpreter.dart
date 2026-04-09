// error_interpreter.dart
// Purpose: Maps raw Dart exceptions and HTTP status codes into structured AppError objects with human-readable guidance.

import 'dart:async';
import 'dart:io';

import '../domain/models/app_error.dart';

abstract final class ErrorInterpreter {
  /// Interprets an exception thrown during request execution.
  static AppError fromException(Object error) {
    if (error is SocketException) return _fromSocketException(error);
    if (error is TimeoutException) return _fromTimeout(error);
    if (error is HandshakeException) return _fromTls(error);
    if (error is HttpException) return _fromHttpException(error);
    if (error is FormatException) return _fromFormat(error);
    if (error is AppError) return error;
    return AppError(
      technical: error.toString(),
      meaning: 'An unexpected error occurred while executing the request.',
      likelyCause: 'An internal or unknown condition prevented the request from completing.',
      nextStep: 'Check the error message above for clues. Try again or inspect the request configuration.',
      category: ErrorCategory.unknown,
    );
  }

  /// Interprets an HTTP response status code into a diagnostic AppError.
  static AppError fromStatusCode(int statusCode) {
    return switch (statusCode) {
      400 => const AppError(
          technical: 'HTTP 400 Bad Request',
          meaning: 'The server could not understand the request due to invalid syntax or an incorrect payload.',
          likelyCause: 'Malformed JSON body, missing required fields, wrong data types, or an incorrect Content-Type header.',
          nextStep: 'Review the request body format and required fields. Verify that Content-Type matches the body. Check the server API documentation for the correct payload schema.',
          category: ErrorCategory.clientError,
        ),
      401 => const AppError(
          technical: 'HTTP 401 Unauthorized',
          meaning: 'The server rejected the request because authentication is missing, invalid, or expired.',
          likelyCause: 'Wrong bearer token, incorrect username or password, expired session, missing Authorization header, or the endpoint requires a prior login step.',
          nextStep: 'Verify the auth type and credentials. Check whether the token has expired. If using Basic Auth, ensure both username and password are correct. You may need to obtain a fresh token first.',
          category: ErrorCategory.auth,
        ),
      403 => const AppError(
          technical: 'HTTP 403 Forbidden',
          meaning: 'The server understood the request and authenticated you, but denied access to the resource.',
          likelyCause: 'The authenticated user does not have permission for this action. The API key may lack the required scope. The resource may be restricted by IP, role, or plan.',
          nextStep: 'Check the permissions or roles associated with your credentials. Review whether this endpoint requires elevated privileges or a specific scope.',
          category: ErrorCategory.auth,
        ),
      404 => const AppError(
          technical: 'HTTP 404 Not Found',
          meaning: 'The server could not find the requested resource at the given URL.',
          likelyCause: 'Incorrect endpoint path, missing path parameter value, the resource has been deleted, or the API version prefix is wrong.',
          nextStep: 'Double-check the endpoint path and any path parameters. Verify the base URL and API version. Consult the API documentation for the correct route.',
          category: ErrorCategory.clientError,
        ),
      405 => const AppError(
          technical: 'HTTP 405 Method Not Allowed',
          meaning: 'The endpoint exists but does not support the HTTP method used.',
          likelyCause: 'Using GET on a POST-only endpoint, or DELETE on a read-only resource.',
          nextStep: 'Check the API documentation for the allowed HTTP methods for this endpoint. Switch to the correct method.',
          category: ErrorCategory.clientError,
        ),
      408 => const AppError(
          technical: 'HTTP 408 Request Timeout',
          meaning: 'The server timed out waiting for the complete request.',
          likelyCause: 'A slow network connection caused the request to arrive too slowly, or the request body is very large.',
          nextStep: 'Check your network connection and try again. If sending a large body, the server may need configuration changes.',
          category: ErrorCategory.timeout,
        ),
      409 => const AppError(
          technical: 'HTTP 409 Conflict',
          meaning: 'The request conflicts with the current state of the resource on the server.',
          likelyCause: 'Trying to create a resource that already exists, or a concurrent modification conflict.',
          nextStep: 'Check whether the resource already exists. Review any unique constraints mentioned in the API documentation.',
          category: ErrorCategory.clientError,
        ),
      410 => const AppError(
          technical: 'HTTP 410 Gone',
          meaning: 'The resource previously existed but has been permanently removed.',
          likelyCause: 'The API has deprecated or deleted this endpoint or resource.',
          nextStep: 'Check the API documentation for a replacement endpoint or an updated API version.',
          category: ErrorCategory.clientError,
        ),
      413 => const AppError(
          technical: 'HTTP 413 Content Too Large',
          meaning: 'The request body is larger than the server is configured to accept.',
          likelyCause: 'Sending a very large JSON payload or file upload that exceeds the server limit.',
          nextStep: 'Reduce the payload size. If uploading files, use a dedicated file-upload endpoint or increase the server limit.',
          category: ErrorCategory.clientError,
        ),
      415 => const AppError(
          technical: 'HTTP 415 Unsupported Media Type',
          meaning: 'The server rejected the request because the body format is not supported for this endpoint.',
          likelyCause: 'Sending JSON with a form-encoded Content-Type, or vice versa. Missing or incorrect Content-Type header.',
          nextStep: 'Verify that the Content-Type header matches the body format (e.g., application/json for JSON). Check the API documentation for the required media type.',
          category: ErrorCategory.clientError,
        ),
      422 => const AppError(
          technical: 'HTTP 422 Unprocessable Entity',
          meaning: 'The server understood the request format but rejected it due to semantic errors or validation failures.',
          likelyCause: 'A required field contains an invalid value, a business rule was violated, or the data fails server-side validation.',
          nextStep: 'Read the response body for validation details. Correct the invalid field values and retry.',
          category: ErrorCategory.clientError,
        ),
      429 => const AppError(
          technical: 'HTTP 429 Too Many Requests',
          meaning: 'You have exceeded the API rate limit.',
          likelyCause: 'Sending too many requests in a short time window.',
          nextStep: 'Wait before retrying. Check the Retry-After header if present. Review the API rate limit documentation.',
          category: ErrorCategory.clientError,
        ),
      500 => const AppError(
          technical: 'HTTP 500 Internal Server Error',
          meaning: 'The server encountered an unexpected error and could not fulfill the request.',
          likelyCause: 'A bug or unhandled exception in the server code. The server may be misconfigured or the backend service is in a bad state.',
          nextStep: 'This is a server-side problem. Check server logs if accessible. Try again later or contact the API provider.',
          category: ErrorCategory.serverError,
        ),
      501 => const AppError(
          technical: 'HTTP 501 Not Implemented',
          meaning: 'The server does not support the functionality required to fulfill the request.',
          likelyCause: 'The HTTP method or feature is not implemented by this server.',
          nextStep: 'Check the API documentation. This endpoint or method may not be available.',
          category: ErrorCategory.serverError,
        ),
      502 => const AppError(
          technical: 'HTTP 502 Bad Gateway',
          meaning: 'The server is acting as a gateway and received an invalid response from the upstream service.',
          likelyCause: 'The backend service is down, restarting, or returning unexpected data to the gateway.',
          nextStep: 'Try again in a moment. This is typically a temporary infrastructure issue. Check the API provider status page.',
          category: ErrorCategory.serverError,
        ),
      503 => const AppError(
          technical: 'HTTP 503 Service Unavailable',
          meaning: 'The server is temporarily unavailable, usually due to maintenance or overload.',
          likelyCause: 'The service is under maintenance, experiencing high load, or has crashed.',
          nextStep: 'Try again later. Check the Retry-After header if present. Monitor the API provider status.',
          category: ErrorCategory.serverError,
        ),
      504 => const AppError(
          technical: 'HTTP 504 Gateway Timeout',
          meaning: 'The gateway timed out waiting for a response from the upstream service.',
          likelyCause: 'The backend service is slow, overloaded, or unresponsive.',
          nextStep: 'Try again. If this recurs, the upstream service may be degraded. Check the provider status.',
          category: ErrorCategory.timeout,
        ),
      _ when statusCode >= 400 && statusCode < 500 => AppError(
          technical: 'HTTP $statusCode Client Error',
          meaning: 'The server rejected the request due to a problem with the request itself.',
          likelyCause: 'Incorrect request parameters, payload, or authorization.',
          nextStep: 'Review the request details and API documentation.',
          category: ErrorCategory.clientError,
        ),
      _ when statusCode >= 500 => AppError(
          technical: 'HTTP $statusCode Server Error',
          meaning: 'The server encountered an error while processing the request.',
          likelyCause: 'An internal server problem or upstream dependency failure.',
          nextStep: 'Try again later. Check the API provider status if the problem persists.',
          category: ErrorCategory.serverError,
        ),
      _ => AppError(
          technical: 'HTTP $statusCode',
          meaning: 'The server returned an unexpected status code.',
          likelyCause: 'Uncommon or custom response code from this API.',
          nextStep: 'Consult the API documentation for the meaning of this status code.',
          category: ErrorCategory.unknown,
        ),
    };
  }

  static AppError _fromSocketException(SocketException e) {
    // OSError code 11001 / 11004 on Windows = DNS resolution failure
    final code = e.osError?.errorCode;
    if (code == 11001 || code == 11004 || code == -2 || code == 8) {
      return AppError(
        technical: 'DNS Resolution Failed: ${e.message}',
        meaning: 'The hostname in the URL could not be resolved to an IP address.',
        likelyCause: 'The domain name is misspelled, does not exist, or your DNS server is unreachable.',
        nextStep: 'Verify the base URL and hostname spelling. Check your network connection and DNS settings. Confirm the domain exists by visiting it in a browser.',
        category: ErrorCategory.network,
      );
    }
    if (code == 111 || code == 10061) {
      return const AppError(
        technical: 'Connection Refused',
        meaning: 'The server actively refused the connection.',
        likelyCause: 'The server is not running on the specified port, the port is blocked by a firewall, or the service is down.',
        nextStep: 'Confirm the server is running. Check the port number in the URL. Verify firewall rules are not blocking the connection.',
        category: ErrorCategory.network,
      );
    }
    return AppError(
      technical: 'Network Error: ${e.message}',
      meaning: 'A network-level error prevented the request from reaching the server.',
      likelyCause: 'No internet connection, the server is unreachable, or a network interface failure.',
      nextStep: 'Check your internet connection. Verify the base URL is reachable. Try pinging the host from a terminal.',
      category: ErrorCategory.network,
    );
  }

  static AppError _fromTimeout(TimeoutException e) {
    return const AppError(
      technical: 'Request Timed Out',
      meaning: 'The request did not receive a response within the allowed time limit.',
      likelyCause: 'The server is slow, overloaded, or unreachable. A heavy operation may be taking too long to complete.',
      nextStep: 'Try again. If this repeats, check whether the server is responding by accessing its health endpoint. Consider whether the request triggers a long-running operation.',
      category: ErrorCategory.timeout,
    );
  }

  static AppError _fromTls(HandshakeException e) {
    return AppError(
      technical: 'TLS Handshake Failed: ${e.message}',
      meaning: 'A secure connection could not be established because the TLS handshake failed.',
      likelyCause: 'An expired, self-signed, or mismatched SSL certificate. The server may not support the required TLS version.',
      nextStep: 'Verify the server has a valid SSL certificate. If using a self-signed certificate in a development environment, your system trust store may need updating.',
      category: ErrorCategory.tls,
    );
  }

  static AppError _fromHttpException(HttpException e) {
    return AppError(
      technical: 'HTTP Exception: ${e.message}',
      meaning: 'An HTTP-level error occurred while sending or receiving the request.',
      likelyCause: 'The connection was interrupted, a header was malformed, or the server sent an invalid HTTP response.',
      nextStep: 'Check the base URL and headers. Ensure the server is accessible and responding with valid HTTP.',
      category: ErrorCategory.network,
    );
  }

  static AppError _fromFormat(FormatException e) {
    return AppError(
      technical: 'Response Parse Error: ${e.message}',
      meaning: 'The response body could not be parsed as the expected format.',
      likelyCause: 'The server returned malformed JSON, unexpected binary data, or a different content type than expected.',
      nextStep: 'Inspect the raw response body. Verify the Content-Type matches the expected response format.',
      category: ErrorCategory.parsing,
    );
  }
}
