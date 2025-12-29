import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart'; // Apna sahi package name check karein

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // MyApp ki jagah IndustryProApp likhein
    await tester.pumpWidget(const IndustryProApp()); 

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}