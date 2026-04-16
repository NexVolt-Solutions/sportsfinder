class UnfollowUserModel {
  final String message;

  UnfollowUserModel({required this.message});

  factory UnfollowUserModel.fromJson(Map<String, dynamic> json) {
    return UnfollowUserModel(message: json['message'] ?? '');
  }
}
