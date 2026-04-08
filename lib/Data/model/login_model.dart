class LoginModel {
  String? email;
  String? password;
  String? accessToken;
  String? refreshToken;
  String? tokenType;

  LoginModel({
    this.email = "",
    this.password = "",
    this.accessToken = "",
    this.refreshToken = "",
    this.tokenType = "",
  });

  LoginModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
    tokenType = json['token_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    data['access_token'] = accessToken;
    data['refresh_token'] = refreshToken;
    data['token_type'] = tokenType;
    return data;
  }
}
