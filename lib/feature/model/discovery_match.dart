/// Model for a single match displayed on the Discover tab.
class DiscoveryMatch {
  const DiscoveryMatch({
    required this.id,
    required this.title,
    required this.distanceKm,
    required this.sportType,
    required this.location,
    required this.dateTime,
    required this.participantsJoined,
    required this.participantsTotal,
  });

  final String id;
  final String title;
  final double distanceKm;
  final String sportType;
  final String location;
  final String dateTime;
  final int participantsJoined;
  final int participantsTotal;

  String get participantsLabel => '$participantsJoined/$participantsTotal';

  DiscoveryMatch copyWith({
    String? id,
    String? title,

    double? distanceKm,
    String? sportType,
    String? location,
    String? dateTime,

    int? participantsJoined,
    int? participantsTotal,
  }) {
    return DiscoveryMatch(
      id: id ?? this.id,
      title: title ?? this.title,
      distanceKm: distanceKm ?? this.distanceKm,
      sportType: sportType ?? this.sportType,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      participantsJoined: participantsJoined ?? this.participantsJoined,
      participantsTotal: participantsTotal ?? this.participantsTotal,
    );
  }
}
