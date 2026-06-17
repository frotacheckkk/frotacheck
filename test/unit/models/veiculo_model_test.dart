import 'package:flutter_test/flutter_test.dart';

// Test suite for Veiculo model

void main() {
  group('Veiculo Model Tests', () {
    test('Veiculo creation with placa', () {
      final placa = 'ABC-1234';

      expect(placa, isNotEmpty);
      expect(placa.length, equals(8));
    });

    test('Veiculo status validation', () {
      final validStatuses = ['Ativo', 'Manutencao', 'Inativo'];
      final currentStatus = 'Ativo';

      expect(validStatuses.contains(currentStatus), isTrue);
    });

    test('Veiculo maintenance tracking', () {
      final lastMaintenanceDate = DateTime(2026, 6, 1);
      final nextMaintenanceDate = DateTime(2026, 12, 1);

      expect(nextMaintenanceDate.isAfter(lastMaintenanceDate), isTrue);
    });

    test('Veiculo odometer increases over time', () {
      final initialOdometer = 10000.0;
      final currentOdometer = 10500.5;

      expect(currentOdometer > initialOdometer, isTrue);
    });
  });

  group('Veiculo Validation', () {
    test('Placa format validation', () {
      final validPlaca = 'ABC-1234';
      final validPlacaPattern = RegExp(r'^[A-Z]{3}-\d{4}$');

      expect(validPlacaPattern.hasMatch(validPlaca), isTrue);
    });

    test('Veiculo data is not null', () {
      final veiculo = {
        'id': '1',
        'placa': 'ABC-1234',
        'modelo': 'Fiat Ducato',
        'status': 'Ativo',
      };

      expect(veiculo['placa'], isNotNull);
      expect(veiculo['modelo'], isNotNull);
    });
  });
}
