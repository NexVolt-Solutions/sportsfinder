class FollowUserModel {
  final String message;

  FollowUserModel({required this.message});

  factory FollowUserModel.fromJson(Map<String, dynamic> json) {
    return FollowUserModel(message: json['message'] ?? '');
  }
}
