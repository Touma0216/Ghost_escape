// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';
import 'package:my_app/ui/screens/overlay/game_ui_overlay.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('Game screen renders', (WidgetTester tester) async {
    // Build the app with ProviderScope like main.dart does.
    await tester.pumpWidget(
      ProviderScope(
        child: PinoNoTegamiApp(),
      ),
    );
    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
        // Verify that the placeholder game view is displayed.
    expect(find.text('Game View (実装領域)'), findsOneWidget);
    // Verify that the UI overlay widget is part of the widget tree.
    expect(find.byType(GameUiOverlay), findsOneWidget);
  });
}
