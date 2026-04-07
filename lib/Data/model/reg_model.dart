class RegistrationModel {
  String? fullName;
  String? email;
  String? phoneNumber;
  String? password;
  String? confirmPassword;
  bool? acceptTerms;
  String? avatarUrl;
  RegistrationModel({
    this.fullName = "",
    this.email = "",
    this.phoneNumber = "",
    this.password = "",
    this.confirmPassword = "",
    this.acceptTerms = false,
    this.avatarUrl,
  });

  RegistrationModel.fromJson(Map<String, dynamic> json) {
    fullName = json['full_name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    password = json['password'];
    confirmPassword = json['confirm_password'];
    acceptTerms = json['accept_terms'];
    avatarUrl = json['avatar_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['full_name'] = fullName;
    data['email'] = email;
    data['phone_number'] = phoneNumber;
    data['password'] = password;
    data['confirm_password'] = confirmPassword;
    data['accept_terms'] = acceptTerms;
    data['avatar_url'] = avatarUrl;
    return data;
  }
}
