import 'package:flutter/material.dart';

class RideType {
  static const String jeepney = 'Jeepney';
  static const String bus = 'Bus';
  static const String p2pBus = 'P2P bus';
  static const String uvExpress = 'UV Express';
  static const String train = 'MRT/LRT/PNR train';
  static const String ferry = 'Ferry';
  static const String tricycle = 'Tricycle';
  static const String eJeep = 'E-jeep';

  static const List<String> all = [
    jeepney,
    bus,
    p2pBus,
    uvExpress,
    train,
    ferry,
    tricycle,
    eJeep,
  ];

  static IconData getIcon(String type) {
    switch (type) {
      case bus:
      case p2pBus:
        return Icons.directions_bus_rounded;
      case train:
        return Icons.train_rounded;
      case ferry:
        return Icons.directions_boat_rounded;
      case tricycle:
        return Icons.two_wheeler_rounded;
      case uvExpress:
        return Icons.airport_shuttle_rounded;
      case eJeep:
        return Icons.electric_bolt_rounded;
      case jeepney:
      default:
        return Icons.commute_rounded;
    }
  }

  static Color getColor(String type) {
    switch (type) {
      case jeepney:
        return const Color(0xFF1F8A4C);
      case bus:
        return const Color(0xFF2563EB);
      case p2pBus:
        return const Color(0xFF0284C7);
      case uvExpress:
        return const Color(0xFFD97706);
      case train:
        return const Color(0xFF7C3AED);
      case ferry:
        return const Color(0xFF0D9488);
      case tricycle:
        return const Color(0xFFEA580C);
      case eJeep:
        return const Color(0xFF059669);
      default:
        return const Color(0xFF1F8A4C);
    }
  }

  static Color getBackgroundColor(String type) {
    return getColor(type).withAlpha(28);
  }
}
