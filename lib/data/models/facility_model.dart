import 'package:flutter/material.dart';

enum FacilityType {
  facility, // General use like Gym, Tennis Court
  event, // Specific scheduled event
}

class FacilityModel {
  final String id;
  final String name;
  final FacilityType type;
  final int capacity;
  final String photoUrl; // Mock URL or asset path
  final String description;
  final List<String> availableDays; // e.g., ["Mon", "Tue"] or empty for all
  final TimeOfDay openTime;
  final TimeOfDay closeTime;

  const FacilityModel({
    required this.id,
    required this.name,
    required this.type,
    required this.capacity,
    required this.photoUrl,
    required this.description,
    this.availableDays = const [],
    required this.openTime,
    required this.closeTime,
  });
}
