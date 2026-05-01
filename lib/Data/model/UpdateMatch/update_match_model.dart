class UpdateMatchModel {
  final String? id;
  final String? title;
  final String? description;
  final String? sport;
  final String? skillLevel;
  final String? status;
  final String? scheduledAt;
  final int? durationMinutes;
  final int? maxPlayers;
  final String? location;
  final double? latitude;
  final double? longitude;

  UpdateMatchModel({
    this.id,
    this.title,
    this.description,
    this.sport,
    this.skillLevel,
    this.status,
    this.scheduledAt,
    this.durationMinutes,
    this.maxPlayers,
    this.location,
    this.latitude,
    this.longitude,
  });

  factory UpdateMatchModel.fromJson(Map<String, dynamic> json) {
    return UpdateMatchModel(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      sport: json["sport"],
      skillLevel: json["skill_level"],
      status: json["status"],
      scheduledAt: json["scheduled_at"],
      durationMinutes: json["duration_minutes"],
      maxPlayers: json["max_players"],
      location: json["location"],
      latitude: (json["latitude"] as num?)?.toDouble(),
      longitude: (json["longitude"] as num?)?.toDouble(),
    );
  }
}
