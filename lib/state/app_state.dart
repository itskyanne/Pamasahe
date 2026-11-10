import 'package:flutter/material.dart';
import '../data/initial_data.dart';
import '../models/route_step.dart';
import '../models/saved_place.dart';
import '../models/saved_route.dart';
import '../models/transport_line.dart';
import '../models/trip.dart';

enum DiscountType {
  none,
  student,
  senior,
  pwd,
}

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  DiscountType _discountType = DiscountType.student;
  List<SavedPlace> _savedPlaces = [];
  List<SavedRoute> _routes = [];
  List<Trip> _trips = [];
  List<TransportLine> _lines = [];

  int _nextRouteId = 10;
  int _nextTripId = 10;
  int _nextLineId = 300;
  int _nextStepId = 100;

  AppState() {
    _savedPlaces = InitialData.getInitialSavedPlaces();
    _routes = InitialData.getRoutes();
    _trips = InitialData.getTrips();
    _lines = InitialData.getLines();
  }

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  DiscountType get discountType => _discountType;
  bool get hasDiscount => _discountType != DiscountType.none;
  bool get studentDiscount => hasDiscount;

  String get discountTypeName {
    switch (_discountType) {
      case DiscountType.student:
        return 'Student';
      case DiscountType.senior:
        return 'Senior Citizen';
      case DiscountType.pwd:
        return 'PWD';
      case DiscountType.none:
        return 'Regular';
    }
  }

  String get discountBadgeText {
    switch (_discountType) {
      case DiscountType.student:
        return '20% Student discount';
      case DiscountType.senior:
        return '20% Senior Citizen discount';
      case DiscountType.pwd:
        return '20% PWD discount';
      case DiscountType.none:
        return 'Regular fare';
    }
  }

  List<String> get savedPlaces => _savedPlaces.map((p) => p.name).toList();
  List<SavedPlace> get savedPlaceObjects => List.unmodifiable(_savedPlaces);
  List<SavedRoute> get routes => List.unmodifiable(_routes);
  List<Trip> get trips => List.unmodifiable(_trips);
  List<TransportLine> get lines => List.unmodifiable(_lines);

  // Settings
  void toggleTheme([bool? isDark]) {
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    } else {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setDiscountType(DiscountType type) {
    _discountType = type;
    notifyListeners();
  }

  void toggleStudentDiscount([bool? value]) {
    if (value != null) {
      _discountType = value ? DiscountType.student : DiscountType.none;
    } else {
      _discountType = hasDiscount ? DiscountType.none : DiscountType.student;
    }
    notifyListeners();
  }

  void addSavedPlaceItem(SavedPlace place) {
    final existingIndex = _savedPlaces.indexWhere((p) => p.name.toLowerCase() == place.name.toLowerCase());
    if (existingIndex != -1) {
      _savedPlaces[existingIndex] = place;
    } else {
      _savedPlaces.add(place);
    }
    notifyListeners();
  }

  void addSavedPlace(String place) {
    final trimmed = place.trim();
    if (trimmed.isNotEmpty && !_savedPlaces.any((p) => p.name.toLowerCase() == trimmed.toLowerCase())) {
      _savedPlaces.add(
        SavedPlace(
          name: trimmed,
          latitude: 7.0707,
          longitude: 125.6087,
          address: 'Downtown, Davao City',
          category: 'Other',
        ),
      );
      notifyListeners();
    }
  }

  void deleteSavedPlace(String place) {
    _savedPlaces.removeWhere((p) => p.name == place);
    notifyListeners();
  }

  // Routes
  SavedRoute? getRouteById(int id) {
    try {
      return _routes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  void addRoute(SavedRoute route) {
    final newRoute = route.copyWith(id: _nextRouteId++);
    _routes.insert(0, newRoute);
    notifyListeners();
  }

  void updateRoute(SavedRoute route) {
    final index = _routes.indexWhere((r) => r.id == route.id);
    if (index != -1) {
      _routes[index] = route;
      notifyListeners();
    }
  }

  void deleteRoute(int routeId) {
    _routes.removeWhere((r) => r.id == routeId);
    // Deleting a route must not delete previously logged trips
    notifyListeners();
  }

  SavedRoute reverseRoute(SavedRoute original) {
    // Reverse the order of steps
    final reversedSteps = original.steps.reversed.map((s) {
      return RouteStep(
        id: _nextStepId++,
        rideType: s.rideType,
        boardingPoint: s.boardingPoint,
        fare: s.fare,
      );
    }).toList();

    final returnRoute = SavedRoute(
      id: _nextRouteId++,
      name: '${original.name} (return)',
      from: original.to,
      to: original.from,
      travelTimeMinutes: original.travelTimeMinutes,
      steps: reversedSteps,
      faresUpdated: 'Nov 6, 2026',
      faresOutdated: false,
    );

    _routes.insert(0, returnRoute);
    notifyListeners();
    return returnRoute;
  }

  // Trips
  void logTrip({
    required int routeId,
    required String routeName,
    required double amount,
    required String date,
  }) {
    final newTrip = Trip(
      id: _nextTripId++,
      routeId: routeId,
      routeName: routeName,
      date: date,
      amount: amount,
    );
    // Sort history newest first
    _trips.insert(0, newTrip);
    notifyListeners();
  }

  void deleteTrip(int tripId) {
    _trips.removeWhere((t) => t.id == tripId);
    notifyListeners();
  }

  // Transport Lines
  TransportLine? getLineById(int id) {
    try {
      return _lines.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  void addLine(TransportLine line) {
    final newLine = line.copyWith(id: _nextLineId++);
    _lines.insert(0, newLine);
    notifyListeners();
  }

  void updateLine(TransportLine line) {
    final index = _lines.indexWhere((l) => l.id == line.id);
    if (index != -1) {
      _lines[index] = line;
      notifyListeners();
    }
  }

  void deleteLine(int lineId) {
    _lines.removeWhere((l) => l.id == lineId);
    // Deleting a line must not modify existing route steps previously created
    notifyListeners();
  }

  // Calculations for Spending and Charts
  double get weeklySpending {
    // Current week total (sum of trips in Nov 2 - Nov 8 week)
    return _trips.fold(0.0, (sum, trip) => sum + trip.amount);
  }

  double get monthlySpending {
    return _trips.fold(0.0, (sum, trip) => sum + trip.amount);
  }

  int get weeklyTripCount => _trips.length;
  int get monthlyTripCount => _trips.length;

  double get weeklyStudentSavings {
    if (!hasDiscount) return 0.0;
    // When 20% discount is applied, amount = 0.8 * regular, so savings = amount * 0.25
    return weeklySpending * 0.25;
  }

  double get monthlyStudentSavings {
    if (!hasDiscount) return 0.0;
    return monthlySpending * 0.25;
  }

  // Day-of-week breakdown (Mon to Sun)
  Map<String, double> get weeklySpendingByDay {
    final Map<String, double> dayTotals = {
      'Mon': 0.0,
      'Tue': 0.0,
      'Wed': 0.0,
      'Thu': 0.0,
      'Fri': 0.0,
      'Sat': 0.0,
      'Sun': 0.0,
    };

    for (final trip in _trips) {
      final dateLower = trip.date.toLowerCase();
      if (dateLower.contains('nov 2') || dateLower.contains('monday') || dateLower.contains('mon')) {
        dayTotals['Mon'] = (dayTotals['Mon'] ?? 0) + trip.amount;
      } else if (dateLower.contains('nov 3') || dateLower.contains('tuesday') || dateLower.contains('tue')) {
        dayTotals['Tue'] = (dayTotals['Tue'] ?? 0) + trip.amount;
      } else if (dateLower.contains('nov 4') || dateLower.contains('wednesday') || dateLower.contains('wed')) {
        dayTotals['Wed'] = (dayTotals['Wed'] ?? 0) + trip.amount;
      } else if (dateLower.contains('nov 5') || dateLower.contains('thursday') || dateLower.contains('thu')) {
        dayTotals['Thu'] = (dayTotals['Thu'] ?? 0) + trip.amount;
      } else if (dateLower.contains('nov 6') || dateLower.contains('friday') || dateLower.contains('fri')) {
        dayTotals['Fri'] = (dayTotals['Fri'] ?? 0) + trip.amount;
      } else if (dateLower.contains('nov 7') || dateLower.contains('saturday') || dateLower.contains('sat')) {
        dayTotals['Sat'] = (dayTotals['Sat'] ?? 0) + trip.amount;
      } else if (dateLower.contains('nov 8') || dateLower.contains('sunday') || dateLower.contains('sun')) {
        dayTotals['Sun'] = (dayTotals['Sun'] ?? 0) + trip.amount;
      } else {
        // Fallback to Friday for newly added trips if not matched
        dayTotals['Fri'] = (dayTotals['Fri'] ?? 0) + trip.amount;
      }
    }

    return dayTotals;
  }
}
