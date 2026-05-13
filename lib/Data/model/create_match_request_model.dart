import 'package:sport_finding/Data/model/discovery_match.dart';

class MatchHost {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final double? avgRating;

  MatchHost({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.avgRating,
  });

  factory MatchHost.fromJson(Map<String, dynamic> json) => MatchHost(
    id: json['id'] ?? '',
    fullName: json['full_name'] ?? '',
    avatarUrl: json['avatar_url'],
    avgRating: (json['avg_rating'] as num?)?.toDouble(),
  );
}

class MatchModel {
  final String id;
  final String title;
  final String? description;
  final String sport;
  final String skillLevel;
  final String status;
  final String? scheduledAt;
  final int? durationMinutes;
  final String? scheduledDate;
  final String? scheduledTime;
  final String? facilityAddress;
  final String? locationName;
  final String? location;
  final double? latitude;
  final double? longitude;
  final int? maxPlayers;
  final int? currentPlayers;
  final MatchHost? host;
  final String? createdAt;

  MatchModel({
    required this.id,
    required this.title,
    this.description,
    required this.sport,
    required this.skillLevel,
    required this.status,
    this.scheduledAt,
    this.durationMinutes,
    this.scheduledDate,
    this.scheduledTime,
    this.facilityAddress,
    this.locationName,
    this.location,
    this.latitude,
    this.longitude,
    this.maxPlayers,
    this.currentPlayers,
    this.host,
    this.createdAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) => MatchModel(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'],
    // API may return sport as a string OR as an object {id,name,...}
    sport: () {
      final raw = json['sport'];
      if (raw is String) return raw;
      if (raw is Map) {
        final m = Map<String, dynamic>.from(raw);
        return m['name']?.toString() ?? m['id']?.toString() ?? '';
      }
      return raw?.toString() ?? '';
    }(),
    skillLevel: json['skill_level'] ?? '',
    status: json['status'] ?? '',
    scheduledAt: json['scheduled_at'],
    durationMinutes: json['duration_minutes'],
    scheduledDate: json['scheduled_date'],
    scheduledTime: json['scheduled_time'],
    facilityAddress: json['facility_address'],
    locationName: json['location_name'],
    location: json['location'],
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    maxPlayers: json['max_players'],
    currentPlayers: json['current_players'],
    host: json['host'] != null ? MatchHost.fromJson(json['host']) : null,
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toJson() => {
    if (title.isNotEmpty) 'title': title,
    if (description != null) 'description': description,
    if (sport.isNotEmpty) 'sport': sport,
    if (skillLevel.isNotEmpty) 'skill_level': skillLevel,
    if (scheduledAt != null) 'scheduled_at': scheduledAt,
    if (scheduledDate != null) 'scheduled_date': scheduledDate,
    if (scheduledTime != null) 'scheduled_time': scheduledTime,
    if (durationMinutes != null) 'duration_minutes': durationMinutes,
    if (facilityAddress != null) 'facility_address': facilityAddress,
    if (locationName != null) 'location_name': locationName,
    if (location != null) 'location': location,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (maxPlayers != null) 'max_players': maxPlayers,
  };
}

 extension ToDiscoveryMatch on MatchModel {
  DiscoveryMatch toDiscoveryMatch() {
    return DiscoveryMatch(
      id: id,
      title: title,
      sportType: sport,
      location:
          location ?? facilityAddress ?? locationName ?? 'Unknown Location',
      date:
          scheduledDate ??
          '14/09/2026', // Fallback to a default if not available
      time:
          scheduledTime ?? '10:00 AM', // Fallback to a default if not available
      participantsJoined: currentPlayers ?? 1,
      participantsTotal: maxPlayers ?? 8,
      players: [host?.fullName ?? 'Host'], // At minimum, add the host
      distanceKm: 0.0, // API doesn't provide distance, set to 0
      hostUserId: host?.id ?? '',
      hostDisplayName: host?.fullName ?? '',
      hostAvatarUrl: host?.avatarUrl,
      skillLevel: skillLevel,
      matchDescription: description ?? '',
      hostBio: '', // API doesn't provide bio
      playerSkills: [], // Will be populated dynamically if needed
      hostMatchesPlayed: 0, // Will be resolved dynamically
      latitude: latitude,
      longitude: longitude,
      durationMinutes: durationMinutes ?? 60,
    );
  }
}
