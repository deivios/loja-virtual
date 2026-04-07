import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('basic material widget renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Loja Virtual'),
        ),
      ),
    );

    expect(find.text('Loja Virtual'), findsOneWidget);
  });
}
