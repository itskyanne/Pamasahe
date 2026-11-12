import 'route_step.dart';

class SavedRoute {
  final int id;
  final String name;
  final String from;
  final String to;
  final int? travelTimeMinutes;
  final List<RouteStep> steps;
  final String faresUpdated;
  final bool faresOutdated;
  final int? monthlyTrips;
  final String? lastUsed;

  const SavedRoute({
    required this.id,
    required this.name,
    required this.from,
    required this.to,
    this.travelTimeMinutes,
    required this.steps,
    required this.faresUpdated,
    this.faresOutdated = false,
    this.monthlyTrips,
    this.lastUsed,
  });

  double get regularTotal {
    return steps.fold(0.0, (sum, step) => sum + step.fare);
  }

  double getDiscountedTotal(bool studentDiscount) {
    if (!studentDiscount) return regularTotal;
    return regularTotal * 0.80;
  }

  double getStepFare(RouteStep step, bool studentDiscount) {
    if (!studentDiscount) return step.fare;
    return step.fare * 0.80;
  }

  SavedRoute copyWith({
    int? id,
    String? name,
    String? from,
    String? to,
    int? travelTimeMinutes,
    List<RouteStep>? steps,
    String? faresUpdated,
    bool? faresOutdated,
    int? monthlyTrips,
    String? lastUsed,
  }) {
    return SavedRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      from: from ?? this.from,
      to: to ?? this.to,
      travelTimeMinutes: travelTimeMinutes ?? this.travelTimeMinutes,
      steps: steps ?? this.steps,
      faresUpdated: faresUpdated ?? this.faresUpdated,
      faresOutdated: faresOutdated ?? this.faresOutdated,
      monthlyTrips: monthlyTrips ?? this.monthlyTrips,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}
