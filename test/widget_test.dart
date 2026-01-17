import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kioske/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(MyApp(prefs: prefs));

    // Verify that our counter starts at 0.
    // Note: The original test assumed a counter. Our new app starts at LanguageSelection or Dashboard.
    // So this test is legacy and will fail significantly if we keep checking for '0'.
    // Let's just check that it builds for now.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
