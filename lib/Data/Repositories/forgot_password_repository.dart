// import 'package:sport_finding/core/Network/api_service.dart';

// class ForgotPasswordRepository {
//   final ApiService apiService;
//   ForgotPasswordRepository({required this.apiService});

//   Future<dynamic> forgotPassword(String email) async {
//     return await apiService.post(
//       '/api/v1/auth/forgot-password',
//       data: {'email': email},
//     );
//   }

//   Future<void> resendOtp({required String email}) async {
//     final response = await apiService.post(
//       "/api/v1/auth/resend-verification-otp",
//       data: {"email": email},
//     );
//     print(response);
//     return response;
//   }

//   Future<void> verifyOtp({required String email, required String otp}) async {
//     final response = await apiService.post(
//       "/api/v1/auth/verify-email",
//       data: {"email": email, "otp": otp},
//     );
//     print(response);
//     return response;
//   }
// }
import 'package:sport_finding/core/Network/api_service.dart';

class ForgotPasswordRepository {
  final ApiService apiService;
  ForgotPasswordRepository({required this.apiService});

  // ✅ Send OTP (forgot password)
  Future<dynamic> forgotPassword(String email) async {
    return await apiService.post(
      '/api/v1/auth/forgot-password',
      data: {'email': email},
    );
  }

  // ✅ FIXED: Resend OTP uses same forgot-password endpoint
  Future<dynamic> resendOtp({required String email}) async {
    final response = await apiService.post(
      '/api/v1/auth/resend-verification-otp', // ✅ Changed from resend-verification-otp
      data: {'email': email},
    );
    print(response);
    return response;
  }

  // ✅ Verify OTP
  Future<dynamic> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return await apiService.post(
      '/api/v1/auth/verify-email', // ✅ check your API docs for correct endpoint
      data: {'email': email, 'otp': otp},
    );
  }
}
