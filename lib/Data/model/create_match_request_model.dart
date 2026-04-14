class CreateMatchRequestModel {
  final String title;
  final String description;
  final String sport;
  final String facilityAddress;
  final String location;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime scheduledAt;
  final String date;
  final String time;
  final int durationMinutes;
  final int maxPlayers;
  final String skillLevel;

  CreateMatchRequestModel({
    required this.title,
    required this.description,
    required this.sport,
    required this.facilityAddress,
    required this.location,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.scheduledAt,
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.maxPlayers,
    required this.skillLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "sport": sport,
      "facility_address": facilityAddress,
      "location": location,
      "location_name": locationName,
      "latitude": latitude,
      "longitude": longitude,
      "scheduled_at": scheduledAt.toUtc().toIso8601String(),
      "date": date,
      "time": time,
      "duration_minutes": durationMinutes,
      "max_players": maxPlayers,
      "skill_level": skillLevel,
    };
  }
}
