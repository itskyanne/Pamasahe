class Trip {
  final int id;
  final int routeId;
  final String routeName;
  final String date; // e.g. "Nov 5, 2026" or "2026-11-05"
  final double amount;

  const Trip({
    required this.id,
    required this.routeId,
    required this.routeName,
    required this.date,
    required this.amount,
  });

  Trip copyWith({
    int? id,
    int? routeId,
    String? routeName,
    String? date,
    double? amount,
  }) {
    return Trip(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      date: date ?? this.date,
      amount: amount ?? this.amount,
    );
  }
}
