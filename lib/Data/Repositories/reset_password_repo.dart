import 'package:flutter/material.dart';
import 'package:sport_finding/Data/model/reset_password_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class ResetPasswordRepo {
  final ApiService _apiService = ApiService();

  Future<ResetPasswordModel> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    debugPrint("🟡 [RESET PASSWORD REPO] API CALL STARTED");
    debugPrint("📩 Email: $email");
    debugPrint("🔐 OTP: $otp");
    debugPrint("🔑 New Password: $newPassword");

    try {
      final response = await _apiService.post(
        "/api/v1/auth/reset-password",
        data: {"email": email, "otp": otp, "new_password": newPassword},
      );

      debugPrint("🟢 [RESET PASSWORD REPO] RESPONSE RECEIVED");
      debugPrint("📦 Response: $response");

      final model = ResetPasswordModel.fromJson(response);

      debugPrint("✅ Parsed Message: ${model.message}");

      return model;
    } catch (e) {
      debugPrint("🔴 [RESET PASSWORD REPO] ERROR OCCURRED");
      debugPrint("❌ Error: $e");
      rethrow;
    }
  }
}
