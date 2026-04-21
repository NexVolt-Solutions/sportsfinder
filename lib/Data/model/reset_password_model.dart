class ResetPasswordModel {
  final String resetToken;
  final String newPassword;
  final String confirmPassword;
  final String message;

  ResetPasswordModel({
    this.resetToken = '',
    this.newPassword = '',
    this.confirmPassword = '',
    required this.message,
  });

  factory ResetPasswordModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordModel(
      resetToken: json['reset_token']?.toString() ?? '',
      newPassword: json['new_password']?.toString() ?? '',
      confirmPassword: json['confirm_password']?.toString() ?? '',
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "reset_token": resetToken,
      "new_password": newPassword,
      "confirm_password": confirmPassword,
      "message": message,
    };
  }
}
