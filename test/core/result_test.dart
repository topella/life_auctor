import 'package:flutter_test/flutter_test.dart';
import 'package:life_auctor/core/result.dart';
import 'package:life_auctor/core/errors/app_error.dart';

void main() {
  group('Result Pattern Tests', () {
    test('Success should contain data', () {
      const result = Success<String>('test data');

      expect(result.data, 'test data');
    });

    test('Success should work with different types', () {
      const stringResult = Success<String>('hello');
      const intResult = Success<int>(42);
      const listResult = Success<List<int>>([1, 2, 3]);

      expect(stringResult.data, 'hello');
      expect(intResult.data, 42);
      expect(listResult.data, [1, 2, 3]);
    });

    test('Failure should contain error', () {
      const error = NetworkError(message: 'No connection');
      const result = Failure<String>(error);

      expect(result.error, error);
      expect(result.error.message, 'No connection');
    });

    test('Pattern matching should work with Success', () {
      const Result<int> result = Success(42);
      String output = '';

      switch (result) {
        case Success(data: final value):
          output = 'Success: $value';
        case Failure(error: final e):
          output = 'Failure: ${e.message}';
      }

      expect(output, 'Success: 42');
    });

    test('Pattern matching should work with Failure', () {
      const Result<int> result = Failure(NetworkError());
      String output = '';

      switch (result) {
        case Success(data: final value):
          output = 'Success: $value';
        case Failure(error: final e):
          output = 'Failure: ${e.message}';
      }

      expect(output, 'Failure: No internet connection');
    });

    test('Result can be checked with is operator', () {
      const Result<String> success = Success('data');
      const Result<String> failure = Failure(DatabaseError());

      expect(success is Success, true);
      expect(success is Failure, false);
      expect(failure is Success, false);
      expect(failure is Failure, true);
    });
  });
}
