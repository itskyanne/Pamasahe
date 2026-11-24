import 'package:flutter_test/flutter_test.dart';
import 'package:pamasahe/models/ride_type.dart';
import 'package:pamasahe/models/route_step.dart';
import 'package:pamasahe/models/saved_place.dart';
import 'package:pamasahe/models/saved_route.dart';
import 'package:pamasahe/services/supabase_service.dart';
import 'package:pamasahe/state/app_state.dart';

void main() {
  group('Pamasahe AppState & Business Logic Tests', () {
    test('Initial data loads with correct routes, trips, and initial weekly total', () {
      final state = AppState();

      expect(state.routes.length, 4);
      expect(state.trips.length, 4);
      expect(state.savedPlaces, ['Home', 'School', 'Mall', 'City Library']);
      expect(state.studentDiscount, isTrue);

      // Initial trips: 26.40 + 26.40 + 10.40 + 26.40 = 89.60
      expect(state.weeklySpending, closeTo(89.60, 0.01));
    });

    test('Student discount applies 20% discount correctly', () {
      const route = SavedRoute(
        id: 1,
        name: 'Test Route',
        from: 'Home',
        to: 'School',
        steps: [
          RouteStep(id: 1, rideType: RideType.jeepney, boardingPoint: 'Terminal', fare: 20.00),
          RouteStep(id: 2, rideType: RideType.jeepney, boardingPoint: 'Highway', fare: 30.00),
        ],
        faresUpdated: 'Nov 6, 2026',
      );

      // Regular total = 50.00
      expect(route.regularTotal, 50.00);
      // Student total (20% off) = 40.00
      expect(route.getDiscountedTotal(true), 40.00);
      // When student discount is false = 50.00
      expect(route.getDiscountedTotal(false), 50.00);
    });

    test('Reverse route swaps From/To, reverses steps, and adds (return) to name', () {
      final state = AppState();
      final original = state.routes.first; // Home to School
      final returnRoute = state.reverseRoute(original);

      expect(returnRoute.name, '${original.name} (return)');
      expect(returnRoute.from, original.to);
      expect(returnRoute.to, original.from);
      expect(returnRoute.steps.length, original.steps.length);
      // First step of return should match last step of original
      expect(returnRoute.steps.first.rideType, original.steps.last.rideType);
      expect(returnRoute.steps.first.fare, original.steps.last.fare);
    });

    test('Logging a trip updates history newest-first and updates weekly total', () {
      final state = AppState();
      final initialWeekly = state.weeklySpending;

      state.logTrip(
        routeId: 1,
        routeName: 'Home to School',
        amount: 26.40,
        date: 'Nov 6, 2026',
      );

      expect(state.trips.length, 5);
      expect(state.trips.first.amount, 26.40);
      expect(state.trips.first.date, 'Nov 6, 2026');
      expect(state.weeklySpending, closeTo(initialWeekly + 26.40, 0.01));
    });

    test('Deleting a route does not delete previously logged trips', () {
      final state = AppState();
      final tripCount = state.trips.length;

      state.deleteRoute(1);

      expect(state.getRouteById(1), isNull);
      expect(state.trips.length, tripCount);
    });

    test('Adding, editing, and deleting saved places with map location pinning', () {
      final state = AppState();

      const newPlace = SavedPlace(
        name: 'Dormitory',
        latitude: 7.0780,
        longitude: 125.6150,
        address: 'Bajada, Davao City',
        category: 'Home',
      );

      state.addSavedPlaceItem(newPlace);
      expect(state.savedPlaces.contains('Dormitory'), isTrue);
      expect(state.savedPlaceObjects.any((p) => p.name == 'Dormitory' && p.latitude == 7.0780), isTrue);

      // Edit the saved place
      final updatedPlace = newPlace.copyWith(
        name: 'New Dormitory',
        address: 'Roxas Ave, Davao City',
        category: 'Work',
      );
      state.updateSavedPlaceItem('Dormitory', updatedPlace);
      expect(state.savedPlaces.contains('New Dormitory'), isTrue);
      expect(state.savedPlaces.contains('Dormitory'), isFalse);
      expect(state.savedPlaceObjects.firstWhere((p) => p.name == 'New Dormitory').category, 'Work');

      state.deleteSavedPlace('New Dormitory');
      expect(state.savedPlaces.contains('New Dormitory'), isFalse);
    });

    test('Student, Senior Citizen, and PWD discounts apply correctly', () {
      final state = AppState();

      // Default is student
      expect(state.discountType, DiscountType.student);
      expect(state.hasDiscount, isTrue);
      expect(state.discountTypeName, 'Student');

      // Senior citizen
      state.setDiscountType(DiscountType.senior);
      expect(state.discountType, DiscountType.senior);
      expect(state.hasDiscount, isTrue);
      expect(state.discountTypeName, 'Senior Citizen');
      expect(state.discountBadgeText, '20% Senior Citizen discount');

      // PWD
      state.setDiscountType(DiscountType.pwd);
      expect(state.discountType, DiscountType.pwd);
      expect(state.hasDiscount, isTrue);
      expect(state.discountTypeName, 'PWD');
      expect(state.discountBadgeText, '20% PWD discount');

      // Regular / None
      state.setDiscountType(DiscountType.none);
      expect(state.discountType, DiscountType.none);
      expect(state.hasDiscount, isFalse);
      expect(state.discountBadgeText, 'Regular fare');
    });

    test('Transport line catalog contains only authentic Davao City jeepneys', () {
      final state = AppState();

      expect(state.lines.length, greaterThanOrEqualTo(25));
      // Verify non-Davao and non-jeep lines are removed
      expect(state.lines.any((l) => l.name == 'Bus 5 Express'), isFalse);
      expect(state.lines.any((l) => l.name == 'Mabini–Poblacion'), isFalse);
      expect(state.lines.every((l) => l.rideType == RideType.jeepney || l.rideType == RideType.eJeep), isTrue);

      final torilLine = state.lines.firstWhere((l) => l.name.contains('Toril'));
      expect(torilLine.rideType, RideType.jeepney);

      final route1Loop = state.lines.firstWhere((l) => l.name.contains('Route 1'));
      expect(route1Loop.isLoop, isTrue);
    });
  });

  group('Supabase Cloud & Offline-First Integration Tests', () {
    test('SupabaseService operates in offline-resilient mock mode without live keys', () {
      final service = SupabaseService();
      expect(service.isMockMode, isTrue);
    });

    test('Supabase authentication returns valid mock session for email and Google', () async {
      final service = SupabaseService();

      // Email sign in
      final emailResult = await service.signInWithEmail(
        email: 'dwayne.paulino@addu.edu.ph',
        password: 'password123',
      );
      expect(emailResult.success, isTrue);
      expect(emailResult.email, 'dwayne.paulino@addu.edu.ph');
      expect(emailResult.id, isNotEmpty);

      // Google OAuth sign in
      final googleResult = await service.signInWithGoogle();
      expect(googleResult.success, isTrue);
      expect(googleResult.email, contains('@'));
      expect(googleResult.id, isNotEmpty);
    });

    test('AppState updates cloud authentication state and signs out properly', () {
      final state = AppState();
      expect(state.isCloudAuthenticated, isTrue);

      state.signOutCloud();
      expect(state.isCloudAuthenticated, isFalse);
      expect(state.cloudUserEmail, isNull);
      expect(state.cloudUserId, isNull);

      state.setCloudUser('student@addu.edu.ph', 'uuid-1234');
      expect(state.isCloudAuthenticated, isTrue);
      expect(state.cloudUserEmail, 'student@addu.edu.ph');
      expect(state.cloudUserId, 'uuid-1234');
    });

    test('Supabase cloud backup and restore synchronizes routes with AppState', () async {
      final state = AppState();
      state.setCloudUser('student@addu.edu.ph', 'uuid-1234');

      // Backup to cloud
      final backupRes = await state.backupToSupabase();
      expect(backupRes.success, isTrue);
      expect(backupRes.message, contains('Backed up'));
      expect(state.lastCloudSync, isNotNull);

      // Restore from cloud
      final restoreRes = await state.restoreFromSupabase();
      expect(restoreRes.success, isTrue);
      expect(restoreRes.message, contains('Cloud Restore Complete'));
    });

    test('Community shared routes can be fetched and published', () async {
      final service = SupabaseService();

      // Fetch community routes
      final communityRoutes = await service.getCommunityRoutes();
      expect(communityRoutes, isNotEmpty);
      expect(communityRoutes.any((r) => r['name'].toString().contains('Matina')), isTrue);

      // Publish a route to community
      const testRoute = SavedRoute(
        id: 99,
        name: 'Toril to Roxas Night Market',
        from: 'Toril Terminal',
        to: 'Roxas Ave',
        steps: [
          RouteStep(id: 1, rideType: RideType.jeepney, boardingPoint: 'Toril', fare: 25.0),
        ],
        faresUpdated: 'Nov 20, 2026',
      );

      final published = await service.publishRouteToCommunity(
        route: testRoute,
        authorName: 'Dwayne (Student)',
      );
      expect(published, isTrue);
    });

    test('Over-The-Air (OTA) fare updates synchronize lines into AppState catalog', () async {
      final state = AppState();
      final initialCount = state.lines.length;

      final result = await state.checkAndApplyOtaUpdates();
      expect(result.hasUpdates, isTrue);
      expect(result.count, 2);
      expect(result.version, contains('LTFRB'));
      expect(state.lines.length, greaterThanOrEqualTo(initialCount));
    });
  });
}
