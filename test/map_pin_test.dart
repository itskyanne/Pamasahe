import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pamasahe/screens/settings/map_place_picker_screen.dart';
import 'package:pamasahe/state/app_scope.dart';

void main() {
  testWidgets('MapPlacePickerScreen renders center pin above map', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = AppState();
    await tester.pumpWidget(
      AppStateScope(
        notifier: appState,
        child: const MaterialApp(
          home: MapPlacePickerScreen(),
        ),
      ),
    );

    // Initial load timer is 650ms
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    final redPinFinder = find.byWidgetPredicate((widget) {
      return widget is Icon && widget.icon == Icons.location_on_rounded && widget.color == const Color(0xFFE53935);
    });
    expect(redPinFinder, findsOneWidget);
  });
}
