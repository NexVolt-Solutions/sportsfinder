import 'package:sport_finding/Data/model/all_matches_model.dart';

/// GET /api/v1/matches/{match_id} — see OpenAPI `MatchDetailResponse`.
class MatchDetailResponse {
  MatchDetailResponse({
    required this.id,
    required this.title,
    required this.sport,
    required this.skillLevel,
    required this.status,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.facilityAddress,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.host,
    required this.participants,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String sport;
  final String skillLevel;
  final String status;
  final String scheduledAt;
  final int durationMinutes;
  final String scheduledDate;
  final String scheduledTime;
  final String facilityAddress;
  final String location;
  final double? latitude;
  final double? longitude;
  final int maxPlayers;
  final int currentPlayers;
  final MatchHost host;
  final List<MatchPlayerResponse> participants;
  final String createdAt;

  factory MatchDetailResponse.fromJson(Map<String, dynamic> json) {
    final sportRaw = json['sport'];
    final sportStr = sportRaw is String
        ? sportRaw
        : (sportRaw is Map ? sportRaw['value']?.toString() : null) ?? '';

    return MatchDetailResponse(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      sport: sportStr,
      skillLevel: json['skill_level']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      scheduledAt: json['scheduled_at'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      scheduledDate: json['scheduled_date'] ?? '',
      scheduledTime: json['scheduled_time'] ?? '',
      facilityAddress: json['facility_address'] ?? '',
      location: json['location'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      maxPlayers: json['max_players'] ?? 0,
      currentPlayers: json['current_players'] ?? 0,
      host: MatchHost.fromJson(json['host'] is Map ? json['host'] as Map<String, dynamic> : {}),
      participants: (json['participants'] as List<dynamic>? ?? [])
          .map((e) => MatchPlayerResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] ?? '',
    );
  }
}

/// OpenAPI `MatchPlayerResponse`.
class MatchPlayerResponse {
  MatchPlayerResponse({
    required this.user,
    required this.role,
    required this.joinedAt,
  });

  final MatchHost user;
  final String role;
  final String joinedAt;

  factory MatchPlayerResponse.fromJson(Map<String, dynamic> json) {
    final u = json['user'];
    return MatchPlayerResponse(
      user: MatchHost.fromJson(u is Map ? u as Map<String, dynamic> : {}),
      role: json['role']?.toString() ?? '',
      joinedAt: json['joined_at']?.toString() ?? '',
    );
  }

  /// Roster entries that count as joined players (excludes pending invites if API uses roles).
  bool get countsAsJoinedPlayer {
    final r = role.trim().toLowerCase();
    if (r.isEmpty) return true;
    if (r.contains('invit') && r.contains('pend')) return false;
    if (r == 'declined' || r == 'left') return false;
    return true;
  }
}
