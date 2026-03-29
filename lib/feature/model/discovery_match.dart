/// Model for a single match (home, discover, lists, and detail flows).
class DiscoveryMatch {
  const DiscoveryMatch({
    required this.id,
    required this.title,
    required this.distanceKm,
    required this.sportType,
    required this.location,
    required this.date,
    required this.participantsJoined,
    required this.participantsTotal,
    required this.players,
    required this.time,
    this.hostDisplayName = '',
    this.skillLevel = 'Intermediate',
    this.matchDescription = '',
    this.hostBio = '',
    this.playerSkills = const [],
    this.hostMatchesPlayed = 0,
  });

  final String id;
  final String title;
  final double distanceKm;
  final String sportType;
  final String location;
  final String date;
  final String time;
  final int participantsJoined;
  final int participantsTotal;
  final List<String> players;

  /// Shown in host-style blocks; falls back to [title] if empty.
  final String hostDisplayName;
  final String skillLevel;
  final String matchDescription;
  final String hostBio;

  /// Optional per-player skill labels; if shorter than [players], [skillLevel] is used.
  final List<String> playerSkills;

  /// Shown on host profile card; if 0, [resolvedHostMatchesPlayed] derives a value.
  final int hostMatchesPlayed;

  String get participantsLabel => '$participantsJoined/$participantsTotal';

  String get displayHostName =>
      hostDisplayName.isNotEmpty ? hostDisplayName : title;

  String get aboutText {
    if (matchDescription.isNotEmpty) return matchDescription;
    return '$sportType at $location on $date at $time. '
        '$participantsJoined of $participantsTotal spots filled.';
  }

  String get resolvedHostBio {
    if (hostBio.isNotEmpty) return hostBio;
    return 'Organizing $sportType games in this area. '
        'Join for a friendly match—everyone welcome at $skillLevel level.';
  }

  int get resolvedHostMatchesPlayed {
    if (hostMatchesPlayed > 0) return hostMatchesPlayed;
    final n = int.tryParse(id);
    return n != null ? 18 + (n % 28) : 24;
  }

  String playerSkillAt(int index) {
    if (playerSkills.isNotEmpty && index < playerSkills.length) {
      return playerSkills[index];
    }
    return skillLevel;
  }

  DiscoveryMatch copyWith({
    String? id,
    String? title,
    double? distanceKm,
    String? sportType,
    String? location,
    String? date,
    String? time,
    int? participantsJoined,
    int? participantsTotal,
    List<String>? players,
    String? hostDisplayName,
    String? skillLevel,
    String? matchDescription,
    String? hostBio,
    List<String>? playerSkills,
    int? hostMatchesPlayed,
  }) {
    return DiscoveryMatch(
      id: id ?? this.id,
      title: title ?? this.title,
      distanceKm: distanceKm ?? this.distanceKm,
      sportType: sportType ?? this.sportType,
      location: location ?? this.location,
      date: date ?? this.date,
      time: time ?? this.time,
      participantsJoined: participantsJoined ?? this.participantsJoined,
      participantsTotal: participantsTotal ?? this.participantsTotal,
      players: players ?? this.players,
      hostDisplayName: hostDisplayName ?? this.hostDisplayName,
      skillLevel: skillLevel ?? this.skillLevel,
      matchDescription: matchDescription ?? this.matchDescription,
      hostBio: hostBio ?? this.hostBio,
      playerSkills: playerSkills ?? this.playerSkills,
      hostMatchesPlayed: hostMatchesPlayed ?? this.hostMatchesPlayed,
    );
  }
}
