import 'package:clinix/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

/// Validator behavior is the app's first line of UX defense for forms.
void main() {
  group('email', () {
    test('rejects empty values', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('   '), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('rejects malformed emails', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('missing@tld'), isNotNull);
      expect(Validators.email('@no-local.com'), isNotNull);
    });

    test('accepts valid emails', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('first.last+tag@clinix.org.np'), isNull);
    });
  });

  group('password', () {
    test('requires at least 6 characters', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });

  group('confirmPassword', () {
    test('matches or fails', () {
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
      expect(Validators.confirmPassword('abc124', 'abc123'), isNotNull);
    });
  });

  group('phone', () {
    test('handles optional mode', () {
      expect(Validators.phone('', optional: true), isNull);
      expect(Validators.phone('', optional: false), isNotNull);
    });

    test('validates digit count', () {
      expect(Validators.phone('12345'), isNotNull);
      expect(Validators.phone('9812345678'), isNull);
      expect(Validators.phone('+977 98 1234 5678'), isNull);
    });
  });

  group('bloodGroup', () {
    test('valid groups pass', () {
      for (final group in ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']) {
        expect(Validators.bloodGroup(group), isNull, reason: group);
      }
    });

    test('invalid or missing groups fail', () {
      expect(Validators.bloodGroup(null), isNotNull);
      expect(Validators.bloodGroup('X+'), isNotNull);
    });
  });

  group('units', () {
    test('accepts 1-20', () {
      expect(Validators.units('1'), isNull);
      expect(Validators.units('20'), isNull);
    });

    test('rejects zero, negatives, and huge numbers', () {
      expect(Validators.units('0'), isNotNull);
      expect(Validators.units('-2'), isNotNull);
      expect(Validators.units('99'), isNotNull);
      expect(Validators.units('abc'), isNotNull);
    });
  });
}
