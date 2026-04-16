class UpdateProfileModel {
  final String id;
  final String fullName;
  final String? bio;
  final String? location;
  final String? avatarUrl;
  final bool isAdmin;
  final String? status;
  final List<Sport> sports;
  final int totalReviews;
  final Stats stats;

  UpdateProfileModel({
    required this.id,
    required this.fullName,
    this.bio,
    this.location,
    this.avatarUrl,
    required this.isAdmin,
    this.status,
    required this.sports,
    required this.totalReviews,
    required this.stats,
  });

  factory UpdateProfileModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      bio: json['bio'],
      location: json['location'],
      avatarUrl: json['avatar_url'],
      isAdmin: json['is_admin'] ?? false,
      status: json['status'],
      sports: (json['sports'] as List? ?? [])
          .map((e) => Sport.fromJson(e))
          .toList(),
      totalReviews: json['total_reviews'] ?? 0,
      stats: Stats.fromJson(json['stats'] ?? {}),
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
  final int matches;
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
      matches: json['matches'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}
