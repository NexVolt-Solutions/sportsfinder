import 'package:sport_finding/core/Network/api_service.dart';

class OtpVerificationRepository {
  final ApiService apiService;
  OtpVerificationRepository({required this.apiService});

  Future<void> verifyOtp({required String email, required String otp}) async {
    final response = await apiService.post(
      "/api/v1/auth/verify-email",
      data: {"email": email, "otp": otp},
    );
    print(response);
    return response;
  }

  Future<void> resendOtp({required String email}) async {
    final response = await apiService.post(
      "/api/v1/auth/resend-verification-otp",
      data: {"email": email},
    );
    print(response);
    return response;
  }
}
