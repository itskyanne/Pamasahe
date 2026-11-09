import 'package:flutter/material.dart';

class SavedPlace {
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String category; // 'Home', 'School', 'Mall', 'Work', 'Terminal', 'Other'

  const SavedPlace({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.category = 'Other',
  });

  IconData get icon {
    switch (category.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'mall':
        return Icons.storefront_rounded;
      case 'work':
        return Icons.business_center_rounded;
      case 'terminal':
        return Icons.directions_bus_rounded;
      case 'other':
      default:
        return Icons.place_rounded;
    }
  }

  Color get color {
    switch (category.toLowerCase()) {
      case 'home':
        return const Color(0xFF1F8A4C);
      case 'school':
        return const Color(0xFF2563EB);
      case 'mall':
        return const Color(0xFFEA580C);
      case 'work':
        return const Color(0xFF7C3AED);
      case 'terminal':
        return const Color(0xFF0D9488);
      default:
        return const Color(0xFF0B3D3A);
    }
  }

  SavedPlace copyWith({
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    String? category,
  }) {
    return SavedPlace(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      category: category ?? this.category,
    );
  }
}
