import 'package:flutter_test/flutter_test.dart';
import 'package:life_auctor/core/errors/app_error.dart';

void main() {
  group('AppError Tests', () {
    test('NetworkError should have correct defaults', () {
      const error = NetworkError();

      expect(error.message, 'No internet connection');
      expect(error.title, 'Network Error');
      expect(error.severity, ErrorSeverity.warning);
      expect(error.originalError, isNull);
    });

    test('NetworkError should accept custom message', () {
      const error = NetworkError(
        message: 'Connection timeout',
        title: 'Timeout',
      );

      expect(error.message, 'Connection timeout');
      expect(error.title, 'Timeout');
    });

    test('DatabaseError should have correct defaults', () {
      const error = DatabaseError();

      expect(error.message, 'Database operation failed');
      expect(error.title, 'Database Error');
      expect(error.severity, ErrorSeverity.error);
    });

    test('AuthenticationError should have correct defaults', () {
      const error = AuthenticationError();

      expect(error.message, 'Authentication failed');
      expect(error.title, 'Authentication Error');
      expect(error.severity, ErrorSeverity.error);
    });

    test('ValidationError should have correct defaults', () {
      const error = ValidationError();

      expect(error.message, 'Invalid data');
      expect(error.title, 'Validation Error');
      expect(error.severity, ErrorSeverity.warning);
    });

    test('SyncError should have correct defaults', () {
      const error = SyncError();

      expect(error.message, 'Synchronization failed');
      expect(error.title, 'Sync Error');
      expect(error.severity, ErrorSeverity.warning);
    });

    test('GenericError should have correct defaults', () {
      const error = GenericError();

      expect(error.message, 'An unexpected error occurred');
      expect(error.title, 'Error');
      expect(error.severity, ErrorSeverity.error);
    });

    test('GenericError should accept custom severity', () {
      const error = GenericError(
        message: 'Critical system failure',
        severity: ErrorSeverity.critical,
      );

      expect(error.severity, ErrorSeverity.critical);
      expect(error.message, 'Critical system failure');
    });

    test('AppError should store originalError', () {
      final originalException = Exception('Original error');
      final error = DatabaseError(
        message: 'Database failed',
        originalError: originalException,
      );

      expect(error.originalError, originalException);
    });

    test('toString should return message', () {
      const error = NetworkError(message: 'Connection lost');

      expect(error.toString(), 'Connection lost');
    });

    test('ErrorSeverity should have all levels', () {
      expect(ErrorSeverity.values.length, 4);
      expect(ErrorSeverity.values, contains(ErrorSeverity.info));
      expect(ErrorSeverity.values, contains(ErrorSeverity.warning));
      expect(ErrorSeverity.values, contains(ErrorSeverity.error));
      expect(ErrorSeverity.values, contains(ErrorSeverity.critical));
    });
  });
}
