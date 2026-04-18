class UpdateMatchStatusRequestModel {
  final String status;

  UpdateMatchStatusRequestModel({required this.status});

  Map<String, dynamic> toJson() => {'status': status};
}

class UpdateMatchStatusModel {
  final String? id;
  final String? title;
  final String? description;
  final String? sport;
  final String? skillLevel;
  final String? status;
  final String? scheduledAt;
  final int? durationMinutes;
  final String? scheduledDate;
  final String? scheduledTime;
  final String? facilityAddress;
  final String? location;
  final num? latitude;
  final num? longitude;
  final int? maxPlayers;
  final int? currentPlayers;
  final MatchStatusHostModel? host;
  final int? hostGamesPlayed;
  final List<dynamic> participants;
  final String? createdAt;

  UpdateMatchStatusModel({
    this.id,
    this.title,
    this.description,
    this.sport,
    this.skillLevel,
    this.status,
    this.scheduledAt,
    this.durationMinutes,
    this.scheduledDate,
    this.scheduledTime,
    this.facilityAddress,
    this.location,
    this.latitude,
    this.longitude,
    this.maxPlayers,
    this.currentPlayers,
    this.host,
    this.hostGamesPlayed,
    this.participants = const [],
    this.createdAt,
  });

  factory UpdateMatchStatusModel.fromJson(Map<String, dynamic> json) {
    return UpdateMatchStatusModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      sport: json['sport'],
      skillLevel: json['skill_level'],
      status: json['status'],
      scheduledAt: json['scheduled_at'],
      durationMinutes: json['duration_minutes'],
      scheduledDate: json['scheduled_date'],
      scheduledTime: json['scheduled_time'],
      facilityAddress: json['facility_address'],
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      maxPlayers: json['max_players'],
      currentPlayers: json['current_players'],
      host: json['host'] is Map<String, dynamic>
          ? MatchStatusHostModel.fromJson(json['host'] as Map<String, dynamic>)
          : null,
      hostGamesPlayed: json['host_games_played'],
      participants: (json['participants'] as List<dynamic>? ?? const []),
      createdAt: json['created_at'],
    );
  }
}

class MatchStatusHostModel {
  final String? id;
  final String? fullName;
  final String? avatarUrl;
  final num? avgRating;

  MatchStatusHostModel({
    this.id,
    this.fullName,
    this.avatarUrl,
    this.avgRating,
  });

  factory MatchStatusHostModel.fromJson(Map<String, dynamic> json) {
    return MatchStatusHostModel(
      id: json['id'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      avgRating: json['avg_rating'],
    );
  }
}
