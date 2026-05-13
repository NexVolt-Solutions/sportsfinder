class FollowersModel {
  final List<FollowerItem> items;
  final int total;
  final int page;
  final int limit;
  final bool hasNext;
  final bool hasPrev;

  FollowersModel({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
  });

  factory FollowersModel.fromJson(Map<String, dynamic> json) {
    return FollowersModel(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => FollowerItem.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
    );
  }
}

class FollowerItem {
  final String id;
  final String fullName;
  final String? bio;
  final String? location;
  final String? avatarUrl;
  final double avgRating;
  final int totalGamesPlayed;
  final bool isFollowing;
  final List<Sport> sports;

  FollowerItem({
    required this.id,
    required this.fullName,
    required this.bio,
    required this.location,
    required this.avatarUrl,
    required this.avgRating,
    required this.totalGamesPlayed,
    required this.isFollowing,
    required this.sports,
  });

  factory FollowerItem.fromJson(Map<String, dynamic> json) {
    return FollowerItem(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      bio: json['bio'],
      location: json['location'],
      avatarUrl: json['avatar_url'],
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
      totalGamesPlayed: json['total_games_played'] ?? 0,
      isFollowing: json['is_following'] ?? false,
      sports: (json['sports'] as List<dynamic>? ?? [])
          .map((e) => Sport.fromJson(e))
          .toList(),
    );
  }
}

class Sport {
  final String sport;
  final String skillLevel;

  Sport({required this.sport, required this.skillLevel});

  /// Supports flat `{ sport: "Football", skill_level: "..." }` and nested profile
  /// shape `{ sport: { id, name, ... }, skill_level: "..." }`.
  factory Sport.fromJson(dynamic raw) {
    if (raw is! Map) {
      return Sport(sport: '', skillLevel: '');
    }
    final json = Map<String, dynamic>.from(raw);
    final skillRaw = json['skill_level'] ?? json['skillLevel'] ?? '';
    final skillLevel = skillRaw.toString();

    final sportRaw = json['sport'];
    final String sportName;
    if (sportRaw is String) {
      sportName = sportRaw;
    } else if (sportRaw is Map) {
      final sm = Map<String, dynamic>.from(sportRaw);
      final name = sm['name']?.toString().trim() ?? '';
      final id = sm['id']?.toString().trim() ?? '';
      sportName = name.isNotEmpty ? name : id;
    } else {
      sportName = sportRaw?.toString() ?? '';
    }

    return Sport(sport: sportName, skillLevel: skillLevel);
  }
}
