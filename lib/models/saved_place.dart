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

  String get displayTitle => name == 'Mall' ? 'City Mall' : name;

  IconData get icon {
    switch (category.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'mall':
      case 'shop':
        return Icons.storefront_rounded;
      case 'work':
        return Icons.business_center_rounded;
      case 'terminal':
        return Icons.directions_bus_rounded;
      case 'library':
        return Icons.local_library_rounded;
      case 'other':
      default:
        return Icons.place_rounded;
    }
  }

  Color get color {
    switch (category.toLowerCase()) {
      case 'home':
        return const Color(0xFF10B981);
      case 'school':
        return const Color(0xFF3B82F6);
      case 'mall':
      case 'shop':
        return const Color(0xFFEC4899);
      case 'work':
        return const Color(0xFF8B5CF6);
      case 'terminal':
        return const Color(0xFF0D9488);
      case 'library':
        return const Color(0xFFF59E0B);
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
