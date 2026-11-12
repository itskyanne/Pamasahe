import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pamasahe/main.dart';

void main() {
  testWidgets('Pamasahe app smoke test and floating navigation bar interaction', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const PamasaheApp());
    await tester.pumpAndSettle();

    // Verify minimal top bar contains only the Pamasahe wordmark
    expect(find.text('Pamasahe'), findsOneWidget);

    // Verify that all 5 bottom navigation items are present by Key
    expect(find.byKey(const ValueKey('nav_item_home')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav_item_routes')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav_item_lines')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav_item_history')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav_item_settings')), findsOneWidget);

    // Verify outline icons exist
    expect(Icons.route_outlined, isNotNull);
    expect(Icons.home_outlined, isNotNull);
    expect(Icons.directions_bus_outlined, isNotNull);
    expect(Icons.access_time_outlined, isNotNull);
    expect(Icons.settings_outlined, isNotNull);

    // Verify initial Home tab is displayed
    expect(find.text('SPENT THIS WEEK'), findsOneWidget);

    // Navigate to Routes tab
    await tester.tap(find.byKey(const ValueKey('nav_item_routes')));
    await tester.pumpAndSettle();
    expect(find.text('Your regular routes'), findsOneWidget);
    expect(find.text('Search saved routes'), findsOneWidget);

    // Navigate to Lines tab
    await tester.tap(find.byKey(const ValueKey('nav_item_lines')));
    await tester.pumpAndSettle();
    expect(find.text('Available lines'), findsOneWidget);

    // Navigate to History tab
    await tester.tap(find.byKey(const ValueKey('nav_item_history')));
    await tester.pumpAndSettle();
    expect(find.text('History'), findsNWidgets(2));
    expect(find.text('TRIP LOG'), findsOneWidget);
    expect(find.text('Export CSV'), findsOneWidget);

    // Navigate to Settings tab
    await tester.tap(find.byKey(const ValueKey('nav_item_settings')));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsNWidgets(2));
    expect(find.text('YOUR ACCOUNT'), findsOneWidget);
    expect(find.text('Dwayne Paulino'), findsOneWidget);

    // Navigate back to Home tab
    await tester.tap(find.byKey(const ValueKey('nav_item_home')));
    await tester.pumpAndSettle();
    expect(find.text('SPENT THIS WEEK'), findsOneWidget);
  });

  testWidgets('Floating navigation bar tablet constraints test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(768 * 2.0, 1024 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PamasaheApp());
    await tester.pumpAndSettle();

    // Find the ConstrainedBox inside the floating bottom navigation bar
    final constrainedBoxFinder = find.byWidgetPredicate(
      (widget) => widget is ConstrainedBox && widget.constraints.maxWidth == 740,
    );
    expect(constrainedBoxFinder, findsOneWidget);

    final RenderBox renderBox = tester.renderObject(constrainedBoxFinder);
    expect(renderBox.size.width, lessThanOrEqualTo(740.0));
  });

  testWidgets('Routes tab search, live filtering, and trip logging test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PamasaheApp());
    await tester.pumpAndSettle();

    // Navigate to Routes tab
    await tester.tap(find.byKey(const ValueKey('nav_item_routes')));
    await tester.pumpAndSettle();

    // Verify header and initial count
    expect(find.text('YOUR COMMUTE'), findsOneWidget);
    expect(find.text('Your regular routes'), findsOneWidget);
    expect(find.text('4 routes'), findsOneWidget);

    // Search for 'Mall'
    await tester.enterText(find.byType(TextField), 'Mall');
    await tester.pumpAndSettle();

    // Matching routes should be filtered (School to Mall, Mall to Home)
    expect(find.text('2 routes'), findsOneWidget);
    expect(find.text('Home to City Library'), findsNothing);

    // Search for non-existent route
    await tester.enterText(find.byType(TextField), 'Airport');
    await tester.pumpAndSettle();

    expect(find.text('No matching routes'), findsOneWidget);
    expect(find.text('Clear search'), findsOneWidget);

    // Clear search
    await tester.tap(find.text('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('4 routes'), findsOneWidget);

    // Tap 'Log this trip' on the first route card
    await tester.tap(find.text('Log this trip').first);
    await tester.pumpAndSettle();

    // Should open LogTripScreen
    expect(find.text('Log Trip'), findsOneWidget);
  });

  testWidgets('Lines tab transport filters and details expansion test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PamasaheApp());
    await tester.pumpAndSettle();

    // Navigate to Lines tab
    await tester.tap(find.byKey(const ValueKey('nav_item_lines')));
    await tester.pumpAndSettle();

    // Verify header and initial state
    expect(find.text('PUBLIC TRANSPORT'), findsOneWidget);
    expect(find.text('Available lines'), findsOneWidget);
    expect(find.text('Mabini–Poblacion'), findsOneWidget);
    expect(find.text('J01'), findsOneWidget);
    expect(find.text('B12'), findsOneWidget);

    // Filter by 'Bus'
    await tester.tap(find.text('Bus'));
    await tester.pumpAndSettle();

    expect(find.text('University Loop'), findsOneWidget);
    expect(find.text('Mabini–Poblacion'), findsNothing);

    // Filter by 'All'
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('Mabini–Poblacion'), findsOneWidget);

    // Tap to open line details whole screen
    await tester.tap(find.text('Mabini–Poblacion'));
    await tester.pumpAndSettle();

    expect(find.text('Line Details'), findsOneWidget);
    expect(find.text('ROUTE COVERAGE'), findsOneWidget);
    expect(find.textContaining('SERVICE INTERVAL'), findsOneWidget);

    // Verify stops like the old lines interface are shown
    expect(find.text('Key Stops & Waypoints'), findsOneWidget);
    expect(find.text('Public Market'), findsOneWidget);

    // Ensure stops are scrolled into view, then tap Point A and Point B
    await tester.ensureVisible(find.text('Mabini Road').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mabini Road').first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Public Market').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Public Market').first);
    await tester.pumpAndSettle();

    // Verify segment fare estimation is displayed
    expect(find.text('Estimated Segment Fare'), findsOneWidget);
    expect(find.text('Use in a route'), findsOneWidget);
  });

  testWidgets('History tab summary metrics, date filtering, and CSV export test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PamasaheApp());
    await tester.pumpAndSettle();

    // Navigate to History tab
    await tester.tap(find.byKey(const ValueKey('nav_item_history')));
    await tester.pumpAndSettle();

    // Verify Eyebrow, Title, and Description
    expect(find.text('TRIP LOG'), findsOneWidget);
    expect(find.text('History'), findsNWidgets(2));
    expect(find.text('Review your past commutes, fares, and student savings.'), findsOneWidget);

    // Verify Summary metrics labels
    expect(find.text('Total spent'), findsOneWidget);
    expect(find.text('Total trips'), findsOneWidget);
    expect(find.text('You saved'), findsOneWidget);

    // Initial "This month" default displays 18 trips and ₱386.80
    expect(find.text('18'), findsOneWidget);
    expect(find.text('₱386.80'), findsOneWidget);
    expect(find.text('₱96.70'), findsOneWidget);

    // Tap "This week" filter pill
    await tester.tap(find.text('This week'));
    await tester.pumpAndSettle();

    // "This week" displays 4 trips and ₱89.60
    expect(find.text('4'), findsOneWidget);
    expect(find.text('₱89.60'), findsOneWidget);
    expect(find.text('₱22.40'), findsOneWidget);

    // Switch back to "This month"
    await tester.tap(find.text('This month'));
    await tester.pumpAndSettle();
    expect(find.text('18'), findsOneWidget);

    // Tap "Export CSV" button
    await tester.tap(find.text('Export CSV'));
    await tester.pumpAndSettle();

    // Verify CSV copied banner
    expect(find.textContaining('copied to clipboard'), findsOneWidget);
  });

  testWidgets('Settings tab profile, interactive map canvas, saved places, and preferences test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PamasaheApp());
    await tester.pumpAndSettle();

    // Navigate to Settings tab
    await tester.tap(find.byKey(const ValueKey('nav_item_settings')));
    await tester.pumpAndSettle();

    // Header & Profile card
    expect(find.text('YOUR ACCOUNT'), findsOneWidget);
    expect(find.text('Settings'), findsNWidgets(2));
    expect(find.text('Dwayne Paulino'), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);

    // Saved places card
    expect(find.text('PLACES'), findsOneWidget);
    expect(find.text('Your saved places'), findsOneWidget);
    expect(find.text('Add place'), findsOneWidget);
    expect(find.text('Home'), findsNWidgets(2)); // Saved place + nav bar item
    expect(find.text('School'), findsOneWidget);
    expect(find.text('City Mall'), findsOneWidget);

    // Commute Preferences
    expect(find.text('FARES & BUDGET'), findsOneWidget);
    expect(find.text('Commute preferences'), findsOneWidget);
    expect(find.text('Student discount'), findsOneWidget);
    expect(find.text('Weekly budget'), findsOneWidget);
    expect(find.text('₱ 150'), findsOneWidget);

    // Notifications
    expect(find.text('NOTIFICATIONS'), findsOneWidget);
    expect(find.text('Reminders'), findsOneWidget);
    expect(find.text('Trip reminders'), findsOneWidget);
    expect(find.text('Weekly summary'), findsOneWidget);

    // Sign out button
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('Settings tab Add place opens Google Maps place picker and auto-fills fields', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PamasaheApp());
    await tester.pumpAndSettle();

    // Navigate to Settings tab
    await tester.tap(find.byKey(const ValueKey('nav_item_settings')));
    await tester.pumpAndSettle();

    // Tap "Add place"
    await tester.tap(find.text('Add place'));
    await tester.pumpAndSettle();

    // Verify Map Place Picker is opened
    expect(find.text('Drop Pin on Map'), findsOneWidget);
    expect(find.text('Auto-filled'), findsOneWidget);
    expect(find.text('Save Pinned Place'), findsOneWidget);

    // Tap "Save Pinned Place"
    await tester.tap(find.text('Save Pinned Place'));
    await tester.pumpAndSettle();

    // Verify returned to Settings and place was saved banner shown
    expect(find.text('Settings'), findsNWidgets(2));
    expect(find.textContaining('Added'), findsOneWidget);
  });

  testWidgets('Settings tab Edit saved place opens Map Place Picker in edit mode and updates place', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PamasaheApp());
    await tester.pumpAndSettle();

    // Navigate to Settings tab
    await tester.tap(find.byKey(const ValueKey('nav_item_settings')));
    await tester.pumpAndSettle();

    // Scroll down to saved places list and tap edit
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit place').first);
    await tester.pumpAndSettle();

    // Verify Map Place Picker is in Edit mode
    expect(find.text('Edit Saved Place'), findsOneWidget);
    expect(find.text('Update Place'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    // Modify the place name
    final nameField = find.widgetWithText(TextField, 'Home');
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'My Sweet Home');
    await tester.pumpAndSettle();

    // Tap Update Place
    await tester.tap(find.text('Update Place'));
    await tester.pumpAndSettle();

    // Verify returned to Settings and place was updated
    expect(find.text('Settings'), findsNWidgets(2));
    expect(find.textContaining('Updated'), findsOneWidget);
    expect(find.text('My Sweet Home'), findsOneWidget);
  });
}
