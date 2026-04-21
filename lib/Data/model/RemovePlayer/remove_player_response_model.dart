class RemovePlayerResponseModel {
  final String message;

  RemovePlayerResponseModel({required this.message});

  factory RemovePlayerResponseModel.fromJson(Map<String, dynamic> json) {
    return RemovePlayerResponseModel(
      message: (json['message'] ?? '').toString(),
    );
  }
}
