class UpdateProfileModel {
  final String id;
  final String fullName;
  final String? bio;
  final String? avatarUrl;
  final List<Sport> sports;
  final DateTime? updatedAt;

  UpdateProfileModel({
    required this.id,
    required this.fullName,
    this.bio,
    this.avatarUrl,
    required this.sports,
    this.updatedAt,
  });

  factory UpdateProfileModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      bio: json['bio'],
      avatarUrl: json['avatar_url'],
      sports: (json['sports'] as List? ?? [])
          .map((e) => Sport.fromJson(e))
          .toList(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "full_name": fullName,
      "bio": bio,
      "avatar_url": avatarUrl,
      "sports": sports.map((e) => e.toJson()).toList(),
      "updated_at": updatedAt?.toIso8601String(),
    };
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

  Map<String, dynamic> toJson() {
    return {"sport": sport, "skill_level": skillLevel};
  }
}
