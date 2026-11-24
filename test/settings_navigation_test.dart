import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pamasahe/main.dart';
import 'package:pamasahe/screens/settings/settings_tab.dart';
import 'package:pamasahe/state/app_scope.dart';
import 'package:pamasahe/state/app_state.dart';
import 'package:pamasahe/widgets/pamasahe_top_bar.dart';

void main() {
  group('Settings Nested Sub-Page Navigation Flow Tests', () {
    testWidgets('Primary tabs show profile avatar and do NOT show back button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const PamasaheApp());
      await tester.pumpAndSettle();

      // On Home tab, profile avatar is present
      expect(find.byKey(const ValueKey('nav_item_settings')), findsOneWidget);
      // Back button is not present on Home tab
      expect(find.byKey(const ValueKey('settings_back_button')), findsNothing);
      expect(find.text('Pamasahe'), findsOneWidget);
    });

    testWidgets('Settings route conditionally hides profile avatar and shows accessible back button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const PamasaheApp());
      await tester.pumpAndSettle();

      // Tap profile avatar to open Settings
      await tester.tap(find.byKey(const ValueKey('nav_item_settings')));
      await tester.pumpAndSettle();

      // On Settings tab:
      // 1. Profile avatar shortcut is conditionally hidden from header
      expect(find.byKey(const ValueKey('nav_item_settings')), findsNothing);

      // 2. Standard accessible back button is present in top-left
      final backButton = find.byKey(const ValueKey('settings_back_button'));
      expect(backButton, findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      // 3. Semantics verify accessible label "Go back"
      final semanticsFinder = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Go back',
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets('Tapping Settings back button returns to the previous tab (Home)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const PamasaheApp());
      await tester.pumpAndSettle();

      // Start on Home tab
      expect(find.text('SPENT THIS WEEK'), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.byKey(const ValueKey('nav_item_settings')));
      await tester.pumpAndSettle();
      expect(find.text('YOUR ACCOUNT'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byKey(const ValueKey('settings_back_button')));
      await tester.pumpAndSettle();

      // Returned to Home tab
      expect(find.text('SPENT THIS WEEK'), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_item_settings')), findsOneWidget);
    });

    testWidgets('Tapping Settings back button returns to the previous tab when navigated from Routes', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const PamasaheApp());
      await tester.pumpAndSettle();

      // Navigate to Routes tab first
      await tester.tap(find.byKey(const ValueKey('nav_item_routes')));
      await tester.pumpAndSettle();
      expect(find.text('Your regular routes'), findsOneWidget);

      // From Routes, navigate to Settings via top bar avatar
      await tester.tap(find.byKey(const ValueKey('nav_item_settings')));
      await tester.pumpAndSettle();
      expect(find.text('YOUR ACCOUNT'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byKey(const ValueKey('settings_back_button')));
      await tester.pumpAndSettle();

      // Accurately restored previous tab (Routes), not defaulting to Home!
      expect(find.text('Your regular routes'), findsOneWidget);
    });

    testWidgets('Standalone SettingsTab invokes onBack fallback to tab 0 if no custom callback', (WidgetTester tester) async {
      int? navigatedTab;

      await tester.pumpWidget(
        AppStateScope(
          notifier: AppState(),
          child: MaterialApp(
            home: Scaffold(
              body: SettingsTab(
                onNavigateToTab: (tab) => navigatedTab = tab,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the back button
      await tester.tap(find.byKey(const ValueKey('settings_back_button')));
      await tester.pumpAndSettle();

      // Fallback destination to 0 (Home) was triggered
      expect(navigatedTab, 0);
    });

    testWidgets('PamasaheTopBar renders custom title and triggers custom back callback', (WidgetTester tester) async {
      bool backPressed = false;

      await tester.pumpWidget(
        AppStateScope(
          notifier: AppState(),
          child: MaterialApp(
            home: Scaffold(
              body: PamasaheTopBar(
                showBackButton: true,
                title: 'Custom Title',
                onBackPressed: () => backPressed = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.byKey(const ValueKey('settings_back_button')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('settings_back_button')));
      expect(backPressed, isTrue);
    });
  });
}
