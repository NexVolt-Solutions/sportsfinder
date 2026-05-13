class AllMatchesResponse {
  final List<AllMatches> items;
  final int total;
  final int page;
  final int limit;
  final bool hasNext;
  final bool hasPrev;

  AllMatchesResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
  });

  factory AllMatchesResponse.fromJson(Map<String, dynamic> json) {
    return AllMatchesResponse(
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => AllMatches.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
    );
  }
}

class AllMatches {
  final String id;
  final String title;
  final String sport;
  final String skillLevel;
  final String status;
  final String scheduledAt;
  final int durationMinutes;
  final String scheduledDate;
  final String scheduledTime;
  final String locationName;
  final String location;
  final String facilityAddress;
  final double? latitude;
  final double? longitude;
  final int maxPlayers;
  final int currentPlayers;
  final double? distanceKm;

  final MatchHost host;

  AllMatches({
    required this.id,
    required this.title,
    required this.sport,
    required this.skillLevel,
    required this.status,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.locationName,
    required this.location,
    required this.facilityAddress,
    required this.latitude,
    required this.longitude,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.distanceKm,
    required this.host,
  });

  factory AllMatches.fromJson(Map<String, dynamic> json) {
    return AllMatches(
      id: _stringFromJson(json['id']),
      title: _stringFromJson(json['title']),
      sport: _sportNameFromJson(json['sport']),
      skillLevel: _stringFromJson(json['skill_level']),
      status: _stringFromJson(json['status']),
      scheduledAt: _stringFromJson(json['scheduled_at']),
      durationMinutes: json['duration_minutes'] ?? 0,
      scheduledDate: _stringFromJson(json['scheduled_date']),
      scheduledTime: _stringFromJson(json['scheduled_time']),
      locationName: _stringFromJson(json['location_name']),
      location: _stringFromJson(json['location']),
      facilityAddress: _stringFromJson(json['facility_address']),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      maxPlayers: json['max_players'] ?? 0,
      currentPlayers: json['current_players'] ?? 0,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      host: MatchHost.fromJson(_mapFromJson(json['host'])),
    );
  }

  /// API `scheduled_at` (ISO-8601, usually with `Z`). Null if missing or invalid.
  DateTime? get scheduledStartUtc {
    if (scheduledAt.isEmpty) return null;
    return DateTime.tryParse(scheduledAt);
  }
}

String _stringFromJson(dynamic raw) => raw?.toString() ?? '';

String _sportNameFromJson(dynamic raw) {
  if (raw == null) return '';
  if (raw is String) return raw;
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final customName = _stringFromJson(map['custom_name']).trim();
    if (customName.isNotEmpty) return customName;
    final name = _stringFromJson(map['name']).trim();
    if (name.isNotEmpty) return name;
    return _stringFromJson(map['id']);
  }
  return raw.toString();
}

Map<String, dynamic> _mapFromJson(dynamic raw) {
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

class MatchHost {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final double avgRating;

  MatchHost({
    required this.id,
    required this.fullName,
    required this.avatarUrl,
    required this.avgRating,
  });

  factory MatchHost.fromJson(Map<String, dynamic> json) {
    return MatchHost(
      id: _stringFromJson(json['id']),
      fullName: _stringFromJson(json['full_name']),
      avatarUrl: json['avatar_url']?.toString(),
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
    );
  }
}
