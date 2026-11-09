class RouteStep {
  final int id;
  final String rideType;
  final String boardingPoint;
  final double fare;

  const RouteStep({
    required this.id,
    required this.rideType,
    required this.boardingPoint,
    required this.fare,
  });

  RouteStep copyWith({
    int? id,
    String? rideType,
    String? boardingPoint,
    double? fare,
  }) {
    return RouteStep(
      id: id ?? this.id,
      rideType: rideType ?? this.rideType,
      boardingPoint: boardingPoint ?? this.boardingPoint,
      fare: fare ?? this.fare,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rideType': rideType,
      'boardingPoint': boardingPoint,
      'fare': fare,
    };
  }

  factory RouteStep.fromMap(Map<String, dynamic> map) {
    return RouteStep(
      id: map['id'] as int,
      rideType: map['rideType'] as String,
      boardingPoint: map['boardingPoint'] as String,
      fare: (map['fare'] as num).toDouble(),
    );
  }
}
