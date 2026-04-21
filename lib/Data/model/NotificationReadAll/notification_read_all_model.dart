class NotificationReadAllResponseModel {
  final String message;

  NotificationReadAllResponseModel({required this.message});

  factory NotificationReadAllResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationReadAllResponseModel(
      message: (json['message'] ?? '').toString(),
    );
  }
}
