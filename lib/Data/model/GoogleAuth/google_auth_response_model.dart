class GoogleAuthResponseModel {
  const GoogleAuthResponseModel({
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
  });

  final String accessToken;
  final String? refreshToken;
  final String tokenType;

  factory GoogleAuthResponseModel.fromJson(Map<String, dynamic> json) {
    return GoogleAuthResponseModel(
      accessToken:
          (json['access_token'] ?? json['accessToken'] ?? '').toString(),
      refreshToken:
          json['refresh_token']?.toString() ?? json['refreshToken']?.toString(),
      tokenType: (json['token_type'] ?? json['tokenType'] ?? 'bearer')
          .toString(),
    );
  }
}
