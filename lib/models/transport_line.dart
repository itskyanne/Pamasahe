import 'package:flutter/material.dart';

class TransportLine {
  final int id;
  final String name;
  final String rideType;
  final String origin;
  final String destination;
  final String via;
  final String notes;
  final double? distanceKm;
  final bool isLoop;
  final List<String> stops;
  final bool isSample;
  final String? code;
  final String? status;
  final String? frequency;
  final String? routeCoverage;
  final Color? color;

  const TransportLine({
    required this.id,
    required this.name,
    required this.rideType,
    required this.origin,
    required this.destination,
    required this.via,
    required this.notes,
    this.distanceKm,
    this.isLoop = false,
    this.stops = const [],
    this.isSample = true,
    this.code,
    this.status,
    this.frequency,
    this.routeCoverage,
    this.color,
  });

  TransportLine copyWith({
    int? id,
    String? name,
    String? rideType,
    String? origin,
    String? destination,
    String? via,
    String? notes,
    double? distanceKm,
    bool? isLoop,
    List<String>? stops,
    bool? isSample,
    String? code,
    String? status,
    String? frequency,
    String? routeCoverage,
    Color? color,
  }) {
    return TransportLine(
      id: id ?? this.id,
      name: name ?? this.name,
      rideType: rideType ?? this.rideType,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      via: via ?? this.via,
      notes: notes ?? this.notes,
      distanceKm: distanceKm ?? this.distanceKm,
      isLoop: isLoop ?? this.isLoop,
      stops: stops ?? this.stops,
      isSample: isSample ?? this.isSample,
      code: code ?? this.code,
      status: status ?? this.status,
      frequency: frequency ?? this.frequency,
      routeCoverage: routeCoverage ?? this.routeCoverage,
      color: color ?? this.color,
    );
  }
}
