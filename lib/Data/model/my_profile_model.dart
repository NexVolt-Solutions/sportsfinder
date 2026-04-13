class MyProfileModel {
  String? id;
  String? fullName;
  String? email;
  String? bio;
  String? location;
  String? avatarUrl;
  int? avgRating;
  int? totalGamesPlayed;
  String? status;
  List<Sports>? sports;
  String? createdAt;

  MyProfileModel({
    this.id,
    this.fullName,
    this.email,
    this.bio,
    this.location,
    this.avatarUrl,
    this.avgRating,
    this.totalGamesPlayed,
    this.status,
    this.sports,
    this.createdAt,
  });

  MyProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['full_name'];
    email = json['email'];
    bio = json['bio'];
    location = json['location'];
    avatarUrl = json['avatar_url'];
    avgRating = json['avg_rating'];
    totalGamesPlayed = json['total_games_played'];
    status = json['status'];
    if (json['sports'] != null) {
      sports = <Sports>[];
      json['sports'].forEach((v) {
        sports!.add(Sports.fromJson(v));
      });
    }
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['full_name'] = fullName;
    data['email'] = email;
    data['bio'] = bio;
    data['location'] = location;
    data['avatar_url'] = avatarUrl;
    data['avg_rating'] = avgRating;
    data['total_games_played'] = totalGamesPlayed;
    data['status'] = status;
    if (sports != null) {
      data['sports'] = sports!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    return data;
  }
}

class Sports {
  String? sport;
  String? skillLevel;

  Sports({this.sport, this.skillLevel});

  Sports.fromJson(Map<String, dynamic> json) {
    sport = json['sport'];
    skillLevel = json['skill_level'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sport'] = sport;
    data['skill_level'] = skillLevel;
    return data;
  }
}
