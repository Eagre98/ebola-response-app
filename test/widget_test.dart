// test/widget_test.dart

import 'package:ebola_response_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WelcomeScreen has a title and action buttons',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EbolaResponseApp());

    // Verify that the welcome screen title is present.
    expect(find.text('Ebola Response'), findsOneWidget);
    expect(find.text('Congo Region'), findsOneWidget);

    // Verify that the main action buttons are present.
    expect(find.widgetWithText(ElevatedButton, 'Get Information (Chatbot)'),
        findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Apply for Medical Team'),
        findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Staff Portal Login'),
        findsOneWidget);
  });
}
