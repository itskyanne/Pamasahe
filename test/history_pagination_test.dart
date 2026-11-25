import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pamasahe/main.dart';

void main() {
  group('History Tab Pagination Tests', () {
    testWidgets('History displays paginated trips (5 per page) and pagination controls', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const PamasaheApp());
      await tester.pumpAndSettle();

      // Navigate to History tab
      await tester.tap(find.byKey(const ValueKey('nav_item_history')));
      await tester.pumpAndSettle();

      // Default "This month" filter has 18 trips total -> 4 pages (5 + 5 + 5 + 3)
      // Check total summary metrics remain accurate for the entire month
      expect(find.text('18'), findsOneWidget);
      expect(find.text('₱386.80'), findsOneWidget);

      // Verify Page 1 summary text
      expect(find.text('Showing 1–5 of 18 trips'), findsOneWidget);
      expect(find.text('Page 1 of 4'), findsOneWidget);

      // Verify page pills [1], [2], [3], [4] exist
      expect(find.byKey(const ValueKey('history_page_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('history_page_2')), findsOneWidget);
      expect(find.byKey(const ValueKey('history_page_3')), findsOneWidget);
      expect(find.byKey(const ValueKey('history_page_4')), findsOneWidget);

      // Verify Prev is disabled on Page 1, Next is enabled
      final prevBtn = find.byKey(const ValueKey('history_pagination_prev'));
      final nextBtn = find.byKey(const ValueKey('history_pagination_next'));
      expect(prevBtn, findsOneWidget);
      expect(nextBtn, findsOneWidget);

      // Tap Next button to go to Page 2
      await tester.ensureVisible(nextBtn);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      expect(find.text('Showing 6–10 of 18 trips'), findsOneWidget);
      expect(find.text('Page 2 of 4'), findsOneWidget);

      // Tap Page 4 directly to jump to the last page
      final page4Btn = find.byKey(const ValueKey('history_page_4'));
      await tester.ensureVisible(page4Btn);
      await tester.tap(page4Btn);
      await tester.pumpAndSettle();

      // Page 4 has 3 remaining trips (items 16 to 18)
      expect(find.text('Showing 16–18 of 18 trips'), findsOneWidget);
      expect(find.text('Page 4 of 4'), findsOneWidget);

      // Tapping Prev on Page 4 navigates back to Page 3
      await tester.ensureVisible(prevBtn);
      await tester.tap(prevBtn);
      await tester.pumpAndSettle();

      expect(find.text('Showing 11–15 of 18 trips'), findsOneWidget);
      expect(find.text('Page 3 of 4'), findsOneWidget);
    });

    testWidgets('Changing date filter resets pagination to Page 1', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const PamasaheApp());
      await tester.pumpAndSettle();

      // Navigate to History tab
      await tester.tap(find.byKey(const ValueKey('nav_item_history')));
      await tester.pumpAndSettle();

      // Advance to Page 2
      final nextBtn = find.byKey(const ValueKey('history_pagination_next'));
      await tester.ensureVisible(nextBtn);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();
      expect(find.text('Page 2 of 4'), findsOneWidget);

      // Switch filter to "This week" (4 trips)
      final thisWeekFilter = find.text('This week');
      await tester.ensureVisible(thisWeekFilter);
      await tester.tap(thisWeekFilter);
      await tester.pumpAndSettle();

      // Should automatically reset to Page 1
      expect(find.text('Showing 1–4 of 4 trips'), findsOneWidget);
      expect(find.text('Page 1 of 1'), findsOneWidget);

      // Switch back to "This month"
      final thisMonthFilter = find.text('This month');
      await tester.ensureVisible(thisMonthFilter);
      await tester.tap(thisMonthFilter);
      await tester.pumpAndSettle();

      // Starts fresh on Page 1
      expect(find.text('Showing 1–5 of 18 trips'), findsOneWidget);
      expect(find.text('Page 1 of 4'), findsOneWidget);
    });
  });
}
