class Trip {
  final int id;
  final int routeId;
  final String routeName;
  final String date; // e.g. "Nov 5, 2026" or "2026-11-05"
  final double amount;
  final String? vehicleType;

  const Trip({
    required this.id,
    required this.routeId,
    required this.routeName,
    required this.date,
    required this.amount,
    this.vehicleType,
  });

  String get vehicle {
    if (vehicleType != null && vehicleType!.isNotEmpty) return vehicleType!.toUpperCase();
    final nameLower = routeName.toLowerCase();
    if (nameLower.contains('bus')) return 'BUS';
    if (nameLower.contains('jeep')) return 'JEEP';
    if (nameLower.contains('train') || nameLower.contains('mrt') || nameLower.contains('lrt')) return 'TRAIN';
    return 'JEEP';
  }

  Trip copyWith({
    int? id,
    int? routeId,
    String? routeName,
    String? date,
    double? amount,
    String? vehicleType,
  }) {
    return Trip(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      vehicleType: vehicleType ?? this.vehicleType,
    );
  }
}
