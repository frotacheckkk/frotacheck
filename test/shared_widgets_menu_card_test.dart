import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frotacheck/shared/widgets/menu_card.dart';

void main() {
  testWidgets('MenuCard displays title and responds to tap', (
    WidgetTester tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MenuCard(
            icon: Icons.directions_car,
            title: 'Veículos',
            color: Colors.blue,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Veículos'), findsOneWidget);
    expect(find.byIcon(Icons.directions_car), findsOneWidget);

    await tester.tap(find.byType(MenuCard));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}
