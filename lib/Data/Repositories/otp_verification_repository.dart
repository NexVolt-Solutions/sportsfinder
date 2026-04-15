import 'package:sport_finding/core/Network/api_service.dart';

class OtpVerificationRepository {
  final ApiService apiService;

  OtpVerificationRepository({required this.apiService});

  Future<dynamic> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      print("========== VERIFY OTP REQUEST ==========");
      print("Endpoint: /api/v1/auth/verify-email");
      print("Email: $email");
      print("OTP: $otp");

      final response = await apiService.post(
        "/api/v1/auth/verify-email",
        data: {"email": email, "otp": otp},
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

  Future<dynamic> resendOtp({required String email}) async {
    try {
      print("========== RESEND OTP REQUEST ==========");
      print("Endpoint: /api/v1/auth/resend-verification-otp");
      print("Email: $email");

      final response = await apiService.post(
        "/api/v1/auth/resend-verification-otp",
        data: {"email": email},
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
}
