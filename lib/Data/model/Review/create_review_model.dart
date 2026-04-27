class CreateReviewRequestModel {
  final int rating;
  final String comment;

  CreateReviewRequestModel({
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'rating': rating,
      'comment': comment,
    };
  }
}

class CreateReviewResponseModel {
  final String id;
  final ReviewUserModel reviewer;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  CreateReviewResponseModel({
    required this.id,
    required this.reviewer,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory CreateReviewResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateReviewResponseModel(
      id: (json['id'] ?? '').toString(),
      reviewer: ReviewUserModel.fromJson(
        Map<String, dynamic>.from(json['reviewer'] ?? const {}),
      ),
      rating: _parseInt(json['rating']),
      comment: (json['comment'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}

class ReviewUserModel {
  final String id;
  final String fullName;
  final String avatarUrl;
  final double avgRating;

  ReviewUserModel({
    required this.id,
    required this.fullName,
    required this.avatarUrl,
    required this.avgRating,
  });

  factory ReviewUserModel.fromJson(Map<String, dynamic> json) {
    return ReviewUserModel(
      id: (json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      avatarUrl: (json['avatar_url'] ?? '').toString(),
      avgRating: _parseDouble(json['avg_rating']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}
