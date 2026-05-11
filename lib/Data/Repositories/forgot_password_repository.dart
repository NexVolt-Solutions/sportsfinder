// ignore_for_file: avoid_print

import 'package:sport_finding/core/Network/api_service.dart';

class ForgotPasswordRepository {
  final ApiService apiService;

  ForgotPasswordRepository({required this.apiService});

  // Send OTP (forgot password)
  Future<dynamic> forgotPassword(String email) async {
    try {
      print("========== FORGOT PASSWORD REQUEST ==========");
      print("Endpoint: /api/v1/auth/forgot-password");
      print("Email: $email");

      final response = await apiService.post(
        '/api/v1/auth/forgot-password',
        data: {'email': email},
      );

      print("========== FORGOT PASSWORD RESPONSE ==========");
      print(response);
      print("========== FORGOT PASSWORD COMPLETED ==========");

      return response;
    } catch (e, stackTrace) {
      print("========== FORGOT PASSWORD ERROR ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
  }

  // Resend OTP
  Future<dynamic> resendOtp({required String email}) async {
    try {
      print("========== RESEND OTP REQUEST ==========");
      print("Endpoint: /api/v1/auth/resend-reset-password-otp");
      print("Email: $email");

      final response = await apiService.post(
        '/api/v1/auth/resend-reset-password-otp',
        data: {'email': email},
      );

      print("========== RESEND OTP RESPONSE ==========");
      print(response);
      print("========== RESEND OTP COMPLETED ==========");

      return response;
    } catch (e, stackTrace) {
      print("========== RESEND OTP ERROR ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
  }

  // Verify OTP
  Future<dynamic> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      print("========== VERIFY OTP REQUEST ==========");
      print("Endpoint: /api/v1/auth/verify-reset-password-otp");
      print("Email: $email");
      print("OTP: $otp");

      final response = await apiService.post(
        '/api/v1/auth/verify-reset-password-otp',
        data: {'email': email, 'otp': otp},
      );

      print("========== VERIFY OTP RESPONSE ==========");
      print(response);
      print("========== VERIFY OTP COMPLETED ==========");

      return response;
    } catch (e, stackTrace) {
      print("========== VERIFY OTP ERROR ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
  }

  // Reset Password
  Future<dynamic> resetPassword({
    required String resetToken,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await apiService.post(
        "/api/v1/auth/reset-password",
        data: {
          "reset_token": resetToken,
          "new_password": password,
          "confirm_password": confirmPassword,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
  // Future<dynamic> resetPassword({
  //   required String password,
  //   required String confirmPassword,
  // }) async {
  //   try {
  //     print("========== RESET PASSWORD REQUEST ==========");
  //     print("Endpoint: /api/v1/auth/reset-password");
  //     print("Password: ${'*' * password.length}");
  //     print("Confirm Password: ${'*' * confirmPassword.length}");

  //     final response = await apiService.post(
  //       '/api/v1/auth/reset-password',
  //       data: {'password': password, 'confirm_password': confirmPassword},
  //     );

  //     print("========== RESET PASSWORD RESPONSE ==========");
  //     print(response);
  //     print("========== RESET PASSWORD COMPLETED ==========");

  //     return response;
  //   } catch (e, stackTrace) {
  //     print("========== RESET PASSWORD ERROR ==========");
  //     print("Error: $e");
  //     print("StackTrace: $stackTrace");
  //     rethrow;
  //   }
  // }
}
