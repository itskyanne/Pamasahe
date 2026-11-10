import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pamasahe/main.dart';

void main() {
  testWidgets('Pamasahe app smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const PamasaheApp());
    await tester.pumpAndSettle();

    // Verify that the bottom navigation items are present.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Routes'), findsOneWidget);
    expect(find.text('Lines'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Verify Spent this week card
    expect(find.text('SPENT THIS WEEK'), findsOneWidget);
  });
}
