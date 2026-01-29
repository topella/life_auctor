import 'package:flutter_test/flutter_test.dart';
import 'package:life_auctor/utils/form_validators.dart';

void main() {
  group('FormValidators Tests', () {
    group('required', () {
      test('should return error for null value', () {
        final validator = FormValidators.required('Name');

        expect(validator(null), 'Please enter Name');
      });

      test('should return error for empty string', () {
        final validator = FormValidators.required('Name');

        expect(validator(''), 'Please enter Name');
      });

      test('should return error for whitespace only', () {
        final validator = FormValidators.required('Name');

        expect(validator('   '), 'Please enter Name');
      });

      test('should return null for valid value', () {
        final validator = FormValidators.required('Name');

        expect(validator('John'), null);
      });
    });

    group('email', () {
      test('should return error for null value', () {
        expect(FormValidators.email(null), 'Please enter email');
      });

      test('should return error for empty string', () {
        expect(FormValidators.email(''), 'Please enter email');
      });

      test('should return error for invalid email format', () {
        expect(FormValidators.email('invalid'), 'Please enter a valid email');
        expect(FormValidators.email('invalid@'), 'Please enter a valid email');
        expect(FormValidators.email('@domain.com'), 'Please enter a valid email');
        expect(FormValidators.email('test@domain'), 'Please enter a valid email');
      });

      test('should return null for valid email', () {
        expect(FormValidators.email('test@example.com'), null);
        expect(FormValidators.email('user.name@domain.org'), null);
        expect(FormValidators.email('user123@test.co'), null);
      });
    });

    group('minLength', () {
      test('should return error for null value', () {
        final validator = FormValidators.minLength(6, 'Password');

        expect(validator(null), 'Please enter Password');
      });

      test('should return error for empty string', () {
        final validator = FormValidators.minLength(6, 'Password');

        expect(validator(''), 'Please enter Password');
      });

      test('should return error for value shorter than minimum', () {
        final validator = FormValidators.minLength(6, 'Password');

        expect(validator('12345'), 'Password must be at least 6 characters');
      });

      test('should return null for value equal to minimum length', () {
        final validator = FormValidators.minLength(6, 'Password');

        expect(validator('123456'), null);
      });

      test('should return null for value longer than minimum', () {
        final validator = FormValidators.minLength(6, 'Password');

        expect(validator('12345678'), null);
      });
    });

    group('numeric', () {
      test('should return null for null value (optional field)', () {
        expect(FormValidators.numeric(null), null);
      });

      test('should return null for empty string (optional field)', () {
        expect(FormValidators.numeric(''), null);
      });

      test('should return error for non-numeric value', () {
        expect(FormValidators.numeric('abc'), 'Please enter a valid number');
        expect(FormValidators.numeric('12.34.56'), 'Please enter a valid number');
        expect(FormValidators.numeric('12a34'), 'Please enter a valid number');
      });

      test('should return null for valid integer', () {
        expect(FormValidators.numeric('123'), null);
        expect(FormValidators.numeric('0'), null);
        expect(FormValidators.numeric('-5'), null);
      });

      test('should return null for valid decimal', () {
        expect(FormValidators.numeric('12.34'), null);
        expect(FormValidators.numeric('0.5'), null);
        expect(FormValidators.numeric('-3.14'), null);
      });
    });
  });
}
