class UpdateProfileModel {
  final String id;
  final String fullName;
  final String? bio;
  final String? location;
  final String? avatarUrl;
  final List<Sport> sports;
  final DateTime? updatedAt;

  UpdateProfileModel({
    required this.id,
    required this.fullName,
    this.bio,
    this.location,
    this.avatarUrl,
    required this.sports,
    this.updatedAt,
  });

  factory UpdateProfileModel.fromJson(Map<String, dynamic> json) {
    final j = Map<String, dynamic>.from(json);
    return UpdateProfileModel(
      id: j['id'] ?? '',
      fullName: j['full_name'] ?? '',
      bio: j['bio'],
      location: j['location']?.toString(),
      avatarUrl: j['avatar_url'],
      sports: (j['sports'] as List? ?? [])
          .map((e) => Sport.fromJson(e))
          .toList(),
      updatedAt: j['updated_at'] != null
          ? DateTime.parse(j['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "full_name": fullName,
      "bio": bio,
      "location": location,
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

  factory Sport.fromJson(dynamic json) {
    final m = json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
    return Sport(
      sport: '${m['sport'] ?? ''}',
      skillLevel: '${m['skill_level'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() {
    return {"sport": sport, "skill_level": skillLevel};
  }
}
