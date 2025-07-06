// This is a basic Flutter widget test for Daily Prayer App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:daily_prayer_new/main.dart';

void main() {
  testWidgets('Daily Prayer App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the app to load
    await tester.pumpAndSettle();

    // Verify that the app title is present
    expect(find.text('매일 기도 루틴'), findsOneWidget);
  });
}
