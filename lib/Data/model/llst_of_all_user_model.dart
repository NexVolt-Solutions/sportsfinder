class ListOfAllUserModel {
  List<Items>? items;
  int? total;
  int? page;
  int? limit;
  bool? hasNext;
  bool? hasPrev;

  ListOfAllUserModel({
    this.items,
    this.total,
    this.page,
    this.limit,
    this.hasNext,
    this.hasPrev,
  });

  ListOfAllUserModel.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    hasNext = json['has_next'];
    hasPrev = json['has_prev'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    data['page'] = page;
    data['limit'] = limit;
    data['has_next'] = hasNext;
    data['has_prev'] = hasPrev;
    return data;
  }
}

class Items {
  String? id;
  String? fullName;
  String? bio;
  String? location;
  String? avatarUrl;
  double? avgRating;
  int? totalGamesPlayed;
  List<Sports>? sports;
  bool? isFollowing;

  Items({
    this.id,
    this.fullName,
    this.bio,
    this.location,
    this.avatarUrl,
    this.avgRating,
    this.totalGamesPlayed,
    this.sports,
    this.isFollowing,
  });

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['full_name'];
    bio = json['bio'];
    location = json['location'];
    avatarUrl = json['avatar_url'];
    avgRating = (json['avg_rating'] as num?)?.toDouble();
    totalGamesPlayed = json['total_games_played'];
    final sportsRaw = json['sports'];
    if (sportsRaw is List) {
      sports = <Sports>[];
      for (final v in sportsRaw) {
        if (v is Map) {
          sports!.add(Sports.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }
    isFollowing = json['is_following'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['full_name'] = fullName;
    data['bio'] = bio;
    data['location'] = location;
    data['avatar_url'] = avatarUrl;
    data['avg_rating'] = avgRating;
    data['total_games_played'] = totalGamesPlayed;
    if (sports != null) {
      data['sports'] = sports!.map((v) => v.toJson()).toList();
    }
    data['is_following'] = isFollowing;
    return data;
  }
}

class Sports {
  String? sport;
  String? skillLevel;

  Sports({this.sport, this.skillLevel});

  Sports.fromJson(Map<String, dynamic> json) {
    sport = _sportLabelFromJson(json['sport']);
    skillLevel = _nullableStringField(json['skill_level']);
  }

  /// API may send `sport` as a string (legacy) or nested `{ id, name, ... }`.
  static String? _sportLabelFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final s = value.trim();
      return s.isEmpty ? null : s;
    }
    if (value is Map) {
      final m = Map<String, dynamic>.from(value);
      final name = '${m['name'] ?? ''}'.trim();
      if (name.isNotEmpty) return name;
      final id = '${m['id'] ?? ''}'.trim();
      if (id.isNotEmpty) return id;
      return null;
    }
    final t = value.toString().trim();
    return t.isEmpty ? null : t;
  }

  static String? _nullableStringField(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final s = value.trim();
      return s.isEmpty ? null : s;
    }
    if (value is Map) {
      final m = Map<String, dynamic>.from(value);
      final name = '${m['name'] ?? m['label'] ?? ''}'.trim();
      if (name.isNotEmpty) return name;
      final id = '${m['id'] ?? m['skill_level'] ?? ''}'.trim();
      if (id.isNotEmpty) return id;
      return null;
    }
    final t = value.toString().trim();
    return t.isEmpty ? null : t;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sport'] = sport;
    data['skill_level'] = skillLevel;
    return data;
  }
}
