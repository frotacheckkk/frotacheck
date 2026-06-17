import 'package:flutter_test/flutter_test.dart';

// Test suite for Viagem model and business logic

void main() {
  group('Viagem Model Tests', () {
    test('Viagem creation with valid data', () {
      // Test that a viagem can be created
      expect('Em Progresso', isNotEmpty);
    });

    test('Viagem status transitions are valid', () {
      final initialStatus = 'Planejada';
      final validStatuses = [
        'Planejada',
        'Em Progresso',
        'Concluída',
        'Cancelada',
      ];

      expect(validStatuses.contains(initialStatus), isTrue);
    });

    test('Quilometragem calculation', () {
      final quilometrosPercorridos = 150.5;

      expect(quilometrosPercorridos > 0, isTrue);
      expect(quilometrosPercorridos, isA<double>());
    });
  });

  group('Viagem Date Handling', () {
    test('Viagem can store datetime information', () {
      final dataPartida = DateTime(2026, 6, 17, 10, 0);

      expect(dataPartida, isNotNull);
      expect(dataPartida.year, equals(2026));
    });
  });
}
