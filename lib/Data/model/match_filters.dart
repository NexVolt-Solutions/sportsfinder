import 'package:flutter/material.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';

/// Slider at max means "any distance" (no distance filtering).
const double kMaxFilterDistanceKm = 100;

/// Sport type shown in the filter sheet.
class SportType {
  final String name;
  final String icon;

  const SportType({required this.name, required this.icon});
}

/// Filter criteria coming from the filter bottom sheet.
class FilterData {
  final int? sportIndex;
  final String? skillLevel;
  final double distance;
  final TimeOfDay? time;
  final DateTime? date;

  FilterData({
    this.sportIndex,
    this.skillLevel,
    required this.distance,
    this.time,
    this.date,
  });

  /// True when sheet choices impose no extra filtering.
  bool get isEffectivelyEmpty =>
      sportIndex == null &&
      (skillLevel == null || skillLevel!.trim().isEmpty) &&
      date == null &&
      time == null &&
      distance >= kMaxFilterDistanceKm - 0.5;
}

/// Applies filter sheet criteria to [source] (AND). Used by list view models.
List<DiscoveryMatch> applyFilterDataToMatches(
  List<DiscoveryMatch> source,
  FilterData data,
) {
  if (data.isEffectivelyEmpty) {
    return List<DiscoveryMatch>.from(source);
  }

  // Must match the sports order shown in the filter sheet.
  const sheetSports = ['Football', 'Basketball', 'Volleyball', 'Tennis'];

  Iterable<DiscoveryMatch> q = source;

  if (data.sportIndex != null) {
    final i = data.sportIndex!.clamp(0, sheetSports.length - 1);
    final name = sheetSports[i];
    q = q.where((m) => m.sportType == name);
  }

  final skill = data.skillLevel?.trim();
  if (skill != null && skill.isNotEmpty) {
    final s = skill.toLowerCase();
    q = q.where((m) => m.skillLevel.trim().toLowerCase() == s);
  }

  if (data.distance < kMaxFilterDistanceKm - 0.5) {
    q = q.where((m) => m.distanceKm <= data.distance);
  }

  if (data.date != null) {
    final d = data.date!;
    q = q.where((m) {
      final start = m.matchScheduledStart;
      if (start == null) return true;
      return start.year == d.year &&
          start.month == d.month &&
          start.day == d.day;
    });
  }

  if (data.time != null) {
    final t = data.time!;
    q = q.where((m) {
      final start = m.matchScheduledStart;
      if (start == null) return true;
      return start.hour == t.hour && start.minute == t.minute;
    });
  }

  return q.toList();
}
