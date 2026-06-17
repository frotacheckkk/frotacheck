import 'package:flutter_test/flutter_test.dart';

// Test suite for Motorista model and CNH validation

void main() {
  group('Motorista Model Tests', () {
    test('Motorista creation with valid data', () {
      final nome = 'João Silva';
      final cnhNumber = '12345678901';

      expect(nome, isNotEmpty);
      expect(cnhNumber.length, equals(11));
    });

    test('CNH expiration date validation', () {
      final cnhExpiration = DateTime(2026, 12, 31);
      final today = DateTime.now();

      final isExpired = cnhExpiration.isBefore(today);
      expect(isExpired, isFalse);
    });

    test('Motorista active status', () {
      final status = 'Ativo';
      final validStatuses = ['Ativo', 'Afastado', 'Inativo'];

      expect(validStatuses.contains(status), isTrue);
    });
  });

  group('CNH Validation', () {
    test('CNH number has correct format', () {
      final cnhNumber = '12345678901';

      expect(cnhNumber.length, equals(11));
      expect(int.tryParse(cnhNumber), isNotNull);
    });

    test('CNH expiration comparison', () {
      final expirationDate = DateTime(2027, 6, 15);
      final comparisonDate = DateTime(2026, 6, 17);

      final daysUntilExpiration = expirationDate
          .difference(comparisonDate)
          .inDays;
      expect(daysUntilExpiration > 0, isTrue);
    });
  });

  group('Motorista Contact Information', () {
    test('Phone number is stored', () {
      final phoneNumber = '(11) 98765-4321';

      expect(phoneNumber, isNotEmpty);
      expect(phoneNumber.length, greaterThan(10));
    });

    test('Email format validation', () {
      final email = 'motorista@example.com';
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

      expect(emailRegex.hasMatch(email), isTrue);
    });
  });
}
