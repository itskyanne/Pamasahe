import 'package:flutter_test/flutter_test.dart';
import 'package:pamasahe/models/ride_type.dart';
import 'package:pamasahe/models/route_step.dart';
import 'package:pamasahe/models/saved_place.dart';
import 'package:pamasahe/models/saved_route.dart';
import 'package:pamasahe/state/app_state.dart';

void main() {
  group('Pamasahe AppState & Business Logic Tests', () {
    test('Initial data loads with correct routes, trips, and initial weekly total', () {
      final state = AppState();

      expect(state.routes.length, 3);
      expect(state.trips.length, 4);
      expect(state.savedPlaces, ['Home', 'School', 'Mall']);
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
          RouteStep(id: 2, rideType: RideType.bus, boardingPoint: 'Highway', fare: 30.00),
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
      final original = state.routes.first; // Home to School (jeep)
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
        routeName: 'Home to School (jeep)',
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

    test('Adding and deleting saved places with map location pinning', () {
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

      state.deleteSavedPlace('Dormitory');
      expect(state.savedPlaces.contains('Dormitory'), isFalse);
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

    test('Transport line catalog has reference lines and Jeep A-12 is removed', () {
      final state = AppState();

      expect(state.lines.length, greaterThanOrEqualTo(25));
      // Verify Jeep A-12 was removed
      expect(state.lines.any((l) => l.name == 'Jeep A-12'), isFalse);

      final bus5 = state.lines.firstWhere((l) => l.name == 'Bus 5 Express');
      expect(bus5.rideType, RideType.bus);
      expect(bus5.isSample, isTrue);

      final route1Loop = state.lines.firstWhere((l) => l.name.contains('Route 1'));
      expect(route1Loop.isLoop, isTrue);
    });
  });
}
