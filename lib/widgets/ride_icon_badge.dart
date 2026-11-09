import 'package:flutter/material.dart';
import '../models/ride_type.dart';

class RideIconBadge extends StatelessWidget {
  final String rideType;
  final double size;
  final double iconSize;

  const RideIconBadge({
    super.key,
    required this.rideType,
    this.size = 40,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final color = RideType.getColor(rideType);
    final bgColor = RideType.getBackgroundColor(rideType);
    final icon = RideType.getIcon(rideType);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: color,
        ),
      ),
    );
  }
}
