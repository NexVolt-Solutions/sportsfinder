class NotificationReadResponseModel {
  final String message;

  NotificationReadResponseModel({required this.message});

  factory NotificationReadResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationReadResponseModel(
      message: (json['message'] ?? '').toString(),
    );
  }
}
