class CreateMatchResponseModel {
  final String id;
  final String title;
  final String description;
  final String sport;
  final String skillLevel;
  final String status;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String scheduledDate;
  final String scheduledTime;
  final String facilityAddress;
  final String locationName;
  final String location;
  final double latitude;
  final double longitude;
  final int maxPlayers;
  final int currentPlayers;
  final Host host;
  final DateTime createdAt;

  CreateMatchResponseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.sport,
    required this.skillLevel,
    required this.status,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.facilityAddress,
    required this.locationName,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.host,
    required this.createdAt,
  });

  factory CreateMatchResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateMatchResponseModel(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      sport: json["sport"] ?? "",
      skillLevel: json["skill_level"] ?? "",
      status: json["status"] ?? "",
      scheduledAt: DateTime.parse(json["scheduled_at"]),
      durationMinutes: json["duration_minutes"] ?? 0,
      scheduledDate: json["scheduled_date"] ?? "",
      scheduledTime: json["scheduled_time"] ?? "",
      facilityAddress: json["facility_address"] ?? "",
      locationName: json["location_name"] ?? "",
      location: json["location"] ?? "",
      latitude: (json["latitude"] ?? 0).toDouble(),
      longitude: (json["longitude"] ?? 0).toDouble(),
      maxPlayers: json["max_players"] ?? 0,
      currentPlayers: json["current_players"] ?? 0,
      host: Host.fromJson(json["host"] ?? {}),
      createdAt: DateTime.parse(json["created_at"]),
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
      id: json["id"] ?? "",
      fullName: json["full_name"] ?? "",
      avatarUrl: json["avatar_url"] ?? "",
      avgRating: (json["avg_rating"] ?? 0).toDouble(),
    );
  }
}
