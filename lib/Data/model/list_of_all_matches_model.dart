class MatchesResponse {
  final List<MatchModel> items;
  final int total;
  final int page;
  final int limit;
  final bool hasNext;
  final bool hasPrev;

  MatchesResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
  });

  factory MatchesResponse.fromJson(Map<String, dynamic> json) {
    return MatchesResponse(
      items: (json['items'] as List)
          .map((e) => MatchModel.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
    );
  }
}

class MatchModel {
  final String id;
  final String title;
  final String sport;
  final String skillLevel;
  final String status;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String scheduledDate;
  final String scheduledTime;
  final String locationName;
  final String location;
  final String facilityAddress;
  final double latitude;
  final double longitude;
  final int maxPlayers;
  final int currentPlayers;
  final double distanceKm;
  final Host host;

  MatchModel({
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

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      sport: json['sport'] ?? '',
      skillLevel: json['skill_level'] ?? '',
      status: json['status'] ?? '',
      scheduledAt: DateTime.parse(json['scheduled_at']),
      durationMinutes: json['duration_minutes'] ?? 0,
      scheduledDate: json['scheduled_date'] ?? '',
      scheduledTime: json['scheduled_time'] ?? '',
      locationName: json['location_name'] ?? '',
      location: json['location'] ?? '',
      facilityAddress: json['facility_address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      maxPlayers: json['max_players'] ?? 0,
      currentPlayers: json['current_players'] ?? 0,
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      host: Host.fromJson(json['host'] ?? {}),
    );
  }
}

class Host {
  final String id;
  final String fullName;
  final String avatarUrl;
  final double avgRating;

  Host({
    required this.id,
    required this.fullName,
    required this.avatarUrl,
    required this.avgRating,
  });

  factory Host.fromJson(Map<String, dynamic> json) {
    return Host(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
    );
  }
}
