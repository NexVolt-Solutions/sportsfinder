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
      id: _nullableString(json['id']),
      title: _nullableString(json['title']),
      description: _nullableString(json['description']),
      sport: _sportLabelFromJson(json['sport']),
      skillLevel: _nullableString(json['skill_level']),
      status: _nullableString(json['status']),
      scheduledAt: _nullableString(json['scheduled_at']),
      durationMinutes: json['duration_minutes'] is int
          ? json['duration_minutes'] as int
          : int.tryParse(json['duration_minutes']?.toString() ?? ''),
      scheduledDate: _nullableString(json['scheduled_date']),
      scheduledTime: _nullableString(json['scheduled_time']),
      facilityAddress: _nullableString(json['facility_address']),
      location: _nullableString(json['location']),
      latitude: json['latitude'] is num ? json['latitude'] as num : null,
      longitude: json['longitude'] is num ? json['longitude'] as num : null,
      maxPlayers: json['max_players'] is int
          ? json['max_players'] as int
          : int.tryParse(json['max_players']?.toString() ?? ''),
      currentPlayers: json['current_players'] is int
          ? json['current_players'] as int
          : int.tryParse(json['current_players']?.toString() ?? ''),
      host: json['host'] is Map<String, dynamic>
          ? MatchStatusHostModel.fromJson(json['host'] as Map<String, dynamic>)
          : json['host'] is Map
              ? MatchStatusHostModel.fromJson(
                  Map<String, dynamic>.from(json['host'] as Map),
                )
              : null,
      hostGamesPlayed: json['host_games_played'] is int
          ? json['host_games_played'] as int
          : int.tryParse(json['host_games_played']?.toString() ?? ''),
      participants: (json['participants'] as List<dynamic>? ?? const []),
      createdAt: _nullableString(json['created_at']),
    );
  }
}

String? _nullableString(dynamic raw) {
  if (raw == null) return null;
  if (raw is String) return raw;
  return raw.toString();
}

/// API may return `sport` as a string id or as `{ id, name, custom_name, ... }`.
String? _sportLabelFromJson(dynamic raw) {
  if (raw == null) return null;
  if (raw is String) {
    final s = raw.trim();
    return s.isEmpty ? null : s;
  }
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final custom = (map['custom_name'] ?? '').toString().trim();
    if (custom.isNotEmpty) return custom;
    final name = (map['name'] ?? '').toString().trim();
    if (name.isNotEmpty) return name;
    final id = (map['id'] ?? '').toString().trim();
    return id.isEmpty ? null : id;
  }
  return raw.toString();
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
