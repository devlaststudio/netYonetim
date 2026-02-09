// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';
import 'package:site_yonetimi_app/main.dart';

void main() {
  testWidgets('App starts with login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SiteYonetApp());

    // Verify that login screen is displayed
    expect(find.text('SiteYönet Pro'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);
  });
}
