import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dosebuddy_ai/main.dart';

void main() {
  testWidgets('DoseBuddy AI loads dashboard screen with welcome header', (WidgetTester tester) async {
    await tester.pumpWidget(const DoseBuddyApp());
    await tester.pumpAndSettle();

    // Verify Title and Welcome banner appear
    expect(find.text('DoseBuddy AI'), findsOneWidget);
    expect(find.textContaining('Good Morning'), findsOneWidget);
  });
}
