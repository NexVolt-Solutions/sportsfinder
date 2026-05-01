import 'package:sport_finding/Data/model/all_matches_model.dart';
import 'package:sport_finding/Data/model/app_user.dart';
import 'package:sport_finding/core/Network/profile_service.dart';

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
    this.hostUserId = '',
    this.hostDisplayName = '',
    this.hostAvatarUrl,
    this.skillLevel = 'Intermediate',
    this.matchDescription = '',
    this.hostBio = '',
    this.playerSkills = const [],
    this.hostMatchesPlayed = 0,
    this.latitude,
    this.longitude,
    this.status = 'pending',
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

  /// Host account id (compare with [AppUser.id] for "my match").
  final String hostUserId;

  /// Shown in host-style blocks; falls back to [title] if empty.
  final String hostDisplayName;
  final String? hostAvatarUrl;
  final String skillLevel;
  final String matchDescription;
  final String hostBio;

  /// Optional per-player skill labels; if shorter than [players], [skillLevel] is used.
  final List<String> playerSkills;

  /// Shown on host profile card; if 0, [resolvedHostMatchesPlayed] derives a value.
  final int hostMatchesPlayed;
  final double? latitude;
  final double? longitude;
  final String status;

  /// Maps API match data into [DiscoveryMatch] (date/time formatted for [matchScheduledStart]).
  factory DiscoveryMatch.fromAllMatches(AllMatches m) {
    final start = _apiScheduledLocal(m);
    final dateStr = start != null
        ? _formatSlashDate(start)
        : (m.scheduledDate.isNotEmpty ? m.scheduledDate : '—');
    final timeStr = start != null
        ? _formatTimeAmPm(start)
        : (m.scheduledTime.isNotEmpty ? m.scheduledTime : '—');

    final loc = m.locationName.isNotEmpty ? m.locationName : m.location;

    return DiscoveryMatch(
      id: m.id,
      title: m.title,
      distanceKm: m.distanceKm ?? 0.0,
      sportType: m.sport,
      location: loc,
      date: dateStr,
      time: timeStr,
      participantsJoined: m.currentPlayers,
      participantsTotal: m.maxPlayers,
      players: const [],
      hostUserId: m.host.id,
      hostDisplayName: m.host.fullName,
      hostAvatarUrl: m.host.avatarUrl,
      skillLevel: m.skillLevel,
      matchDescription: '',
      hostBio: '',
      playerSkills: const [],
      hostMatchesPlayed: 0,
      latitude: m.latitude,
      longitude: m.longitude,
      status: m.status,
    );
  }

  static DateTime? _apiScheduledLocal(AllMatches m) {
    final utc = m.scheduledStartUtc;
    if (utc != null) return utc.toLocal();
    if (m.scheduledDate.isEmpty) return null;
    final t = m.scheduledTime.isEmpty ? '00:00' : m.scheduledTime;
    final normalized = t.length == 5 ? '$t:00' : t;
    return DateTime.tryParse('${m.scheduledDate}T$normalized')?.toLocal();
  }

  static String _formatSlashDate(DateTime local) {
    final d = local.day.toString().padLeft(2, '0');
    final mo = local.month.toString().padLeft(2, '0');
    return '$d/$mo/${local.year}';
  }

  static String _formatTimeAmPm(DateTime local) {
    var hour = local.hour;
    final minute = local.minute;
    final isPm = hour >= 12;
    var h12 = hour % 12;
    if (h12 == 0) h12 = 12;
    final ap = isPm ? 'PM' : 'AM';
    return '$h12:${minute.toString().padLeft(2, '0')} $ap';
  }

  String get participantsLabel => '$participantsJoined/$participantsTotal';

  bool isHostedBy(AppUser user) =>
      hostUserId.isNotEmpty && hostUserId == user.id;

  /// Uses [ProfileService] (logged-in user id from `/users/me`).
  bool get isHostedByCurrentUser {
    final myId = ProfileService().profile?.id;
    if (myId == null || myId.isEmpty) return false;
    return hostUserId.isNotEmpty && hostUserId == myId;
  }

  /// True if the signed-in user is in [players] (by display name) or listed as `'You'`.
  bool get isJoinedByCurrentUser {
    final raw = ProfileService().profile?.fullName.trim() ?? '';
    var n = raw.toLowerCase();
    if (n.isEmpty) {
      n = AppUser.current.displayName.trim().toLowerCase();
    }
    if (n.isEmpty) return false;
    for (final p in players) {
      final t = p.trim().toLowerCase();
      if (t == 'you' || t == n) return true;
    }
    return false;
  }

  /// Hosted or joined — used for the **My Matches** tab (any schedule date).
  bool get involvesCurrentUser =>
      isHostedByCurrentUser || isJoinedByCurrentUser;

  /// Parsed [date] (`dd/MM/yyyy`) + [time] (`h:mm AM/PM`); null if parsing fails.
  DateTime? get matchScheduledStart {
    final dm = _dateSlashPattern.firstMatch(date.trim());
    if (dm == null) return null;
    final day = int.tryParse(dm[1]!);
    final month = int.tryParse(dm[2]!);
    final year = int.tryParse(dm[3]!);
    if (day == null || month == null || year == null) return null;
    final tm = _timeAmPmPattern.firstMatch(time.trim());
    if (tm == null) {
      return DateTime(year, month, day);
    }
    var hour = int.tryParse(tm[1]!);
    final minute = int.tryParse(tm[2]!) ?? 0;
    final ap = tm[3]!.toUpperCase();
    if (hour == null) return DateTime(year, month, day);
    if (ap == 'PM' && hour != 12) hour += 12;
    if (ap == 'AM' && hour == 12) hour = 0;
    return DateTime(year, month, day, hour, minute);
  }

  /// **Upcoming** = scheduled start strictly after [now]. Unparseable dates count as upcoming.
  bool isUpcomingRelativeTo(DateTime now) {
    final start = matchScheduledStart;
    if (start == null) return true;
    return start.isAfter(now);
  }

  static final RegExp _dateSlashPattern = RegExp(
    r'^(\d{1,2})/(\d{1,2})/(\d{4})$',
  );
  static final RegExp _timeAmPmPattern = RegExp(
    r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
    caseSensitive: false,
  );

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
    String? hostUserId,
    String? hostDisplayName,
    String? hostAvatarUrl,
    String? skillLevel,
    String? matchDescription,
    String? hostBio,
    List<String>? playerSkills,
    int? hostMatchesPlayed,
    double? latitude,
    double? longitude,
    String? status,
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
      hostUserId: hostUserId ?? this.hostUserId,
      hostDisplayName: hostDisplayName ?? this.hostDisplayName,
      hostAvatarUrl: hostAvatarUrl ?? this.hostAvatarUrl,
      skillLevel: skillLevel ?? this.skillLevel,
      matchDescription: matchDescription ?? this.matchDescription,
      hostBio: hostBio ?? this.hostBio,
      playerSkills: playerSkills ?? this.playerSkills,
      hostMatchesPlayed: hostMatchesPlayed ?? this.hostMatchesPlayed,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
    );
  }
}
