class CreateReviewRequestModel {
  final String matchId;
  final int rating;
  final String comment;

  CreateReviewRequestModel({
    required this.matchId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {"match_id": matchId, "rating": rating, "comment": comment};
  }
}

class CreateReviewModel {
  final String id;
  final Reviewer reviewer;
  final int rating;
  final String comment;
  final DateTime createdAt;

  CreateReviewModel({
    required this.id,
    required this.reviewer,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory CreateReviewModel.fromJson(Map<String, dynamic> json) {
    return CreateReviewModel(
      id: json['id'] ?? '',
      reviewer: Reviewer.fromJson(json['reviewer'] ?? {}),
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Reviewer {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final double avgRating;
  final int totalGamesPlayed;

  Reviewer({
    required this.id,
    required this.fullName,
    required this.avatarUrl,
    required this.avgRating,
    required this.totalGamesPlayed,
  });

  factory Reviewer.fromJson(Map<String, dynamic> json) {
    return Reviewer(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      avatarUrl: json['avatar_url'],
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
      totalGamesPlayed: json['total_games_played'] ?? 0,
    );
  }
}
