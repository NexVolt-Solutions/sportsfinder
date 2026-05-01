class DeviceTokenRequestModel {
  final String token;
  final String platform;

  DeviceTokenRequestModel({required this.token, required this.platform});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'fcm_token': token, 'platform': platform};
  }
}

class DeviceTokenResponseModel {
  final String? message;

  DeviceTokenResponseModel({this.message});

  factory DeviceTokenResponseModel.fromJson(Map<String, dynamic> json) {
    return DeviceTokenResponseModel(message: json['message']?.toString());
  }
}
