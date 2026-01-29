enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}

// creating a base class for all aplications error
abstract class AppError {
  final String message;
  final String? title;
  final ErrorSeverity severity;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.title,
    this.severity = ErrorSeverity.error,
    this.originalError,
  });

  @override
  String toString() => message;
}


class NetworkError extends AppError {
  const NetworkError({
    String? message,
    String? title,
    super.originalError,
  }) : super(
         message: message ?? 'No internet connection',
         title: title ?? 'Network Error',
         severity: ErrorSeverity.warning,
       );
}

class DatabaseError extends AppError {
  const DatabaseError({
    String? message,
    String? title,
    super.originalError,
  }) : super(
         message: message ?? 'Database operation failed',
         title: title ?? 'Database Error',
         severity: ErrorSeverity.error,
       );
}

class AuthenticationError extends AppError {
  const AuthenticationError({
    String? message,
    String? title,
    super.originalError,
  }) : super(
         message: message ?? 'Authentication failed',
         title: title ?? 'Authentication Error',
         severity: ErrorSeverity.error,
       );
}

class ValidationError extends AppError {
  const ValidationError({
    String? message,
    String? title,
    super.originalError,
  }) : super(
         message: message ?? 'Invalid data',
         title: title ?? 'Validation Error',
         severity: ErrorSeverity.warning,
       );
}

class SyncError extends AppError {
  const SyncError({
    String? message,
    String? title,
    super.originalError,
  }) : super(
         message: message ?? 'Synchronization failed',
         title: title ?? 'Sync Error',
         severity: ErrorSeverity.warning,
       );
}

class FirebaseError extends AppError {
  const FirebaseError({
    String? message,
    String? title,
    super.originalError,
  }) : super(
         message: message ?? 'Firebase operation failed',
         title: title ?? 'Server Error',
         severity: ErrorSeverity.error,
       );
}

class GenericError extends AppError {
  const GenericError({
    String? message,
    String? title,
    super.severity = ErrorSeverity.error,
    super.originalError,
  }) : super(
         message: message ?? 'An unexpected error occurred',
         title: title ?? 'Error',
       );
}
