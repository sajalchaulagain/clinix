/// Human-friendly application exceptions.
///
/// The UI never shows raw platform errors or stack traces. Instead, lower
/// layers (network, Firebase) convert errors into [AppException] subclasses,
/// each carrying a message that is safe to display to users.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  /// Human-friendly message, safe to render in the UI.
  final String message;

  /// Original error object, kept for logging/debugging only.
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

class NoNetworkException extends AppException {
  const NoNetworkException({super.cause})
      : super('No internet connection. Please check your network and retry.');
}

class TimeoutAppException extends AppException {
  const TimeoutAppException({super.cause})
      : super('The request took too long. Please try again.');
}

class ServerException extends AppException {
  const ServerException({super.cause, this.statusCode})
      : super('Our servers are having trouble right now. Please try again soon.');

  final int? statusCode;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({super.cause})
      : super('Your session has expired. Please sign in again.');
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException({super.cause})
      : super('You do not have permission to perform this action.');
}

class NotFoundException extends AppException {
  const NotFoundException([String message = 'The requested item was not found.'])
      : super(message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class AuthException extends AppException {
  const AuthException(super.message, {super.cause});
}

class ImageUploadException extends AppException {
  const ImageUploadException({super.cause})
      : super('We could not process your image. Please try a clearer photo.');
}

class UnknownAppException extends AppException {
  const UnknownAppException({super.cause})
      : super('Something unexpected happened. Please try again.');
}
