class GetUserProfileModel {
  final String id;
  final String fullName;
  final String? bio;
  final String? location;
  final String? avatarUrl;
  final bool isAdmin;
  final int totalReviews;
  final List<dynamic> reviews;
  final List<Sport> sports;
  final Stats stats;
  final Actions actions;

  GetUserProfileModel({
    required this.id,
    required this.fullName,
    required this.bio,
    required this.location,
    required this.avatarUrl,
    required this.isAdmin,
    required this.totalReviews,
    required this.reviews,
    required this.sports,
    required this.stats,
    required this.actions,
  });

  factory GetUserProfileModel.fromJson(Map<String, dynamic> json) {
    return GetUserProfileModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      bio: json['bio'],
      location: json['location'],
      avatarUrl: json['avatar_url'],
      isAdmin: json['is_admin'] ?? false,
      totalReviews: json['total_reviews'] ?? 0,
      reviews: json['reviews'] ?? [],
      sports: (json['sports'] as List<dynamic>? ?? [])
          .map((e) => Sport.fromJson(e))
          .toList(),
      stats: Stats.fromJson(json['stats'] ?? {}),
      actions: Actions.fromJson(json['actions'] ?? {}),
    );
  }
}

class Sport {
  final String sport;
  final String skillLevel;

  Sport({required this.sport, required this.skillLevel});

  factory Sport.fromJson(Map<String, dynamic> json) {
    return Sport(
      sport: json['sport'] ?? '',
      skillLevel: json['skill_level'] ?? '',
    );
  }
}

class Stats {
  final int followers;
  final int following;
  final int? matches;
  final double rating;

  Stats({
    required this.followers,
    required this.following,
    required this.matches,
    required this.rating,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      matches: json['matches'],
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}

class Actions {
  final bool canFollow;
  final bool canMessage;
  final bool canRate;
  final bool isFollowing;
  final bool isOwnProfile;

  Actions({
    required this.canFollow,
    required this.canMessage,
    required this.canRate,
    required this.isFollowing,
    required this.isOwnProfile,
  });

  factory Actions.fromJson(Map<String, dynamic> json) {
    return Actions(
      canFollow: json['can_follow'] ?? false,
      canMessage: json['can_message'] ?? false,
      canRate: json['can_rate'] ?? false,
      isFollowing: json['is_following'] ?? false,
      isOwnProfile: json['is_own_profile'] ?? false,
    );
  }
}
