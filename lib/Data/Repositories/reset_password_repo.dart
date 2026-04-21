import 'package:flutter/material.dart';
import 'package:sport_finding/Data/model/reset_password_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class ResetPasswordRepo {
  final ApiService _apiService = ApiService();

  Future<ResetPasswordModel> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    debugPrint('[ResetPasswordRepo] API call started');
    debugPrint(
      '[ResetPasswordRepo] Reset token present: ${resetToken.isNotEmpty}',
    );
    debugPrint(
      '[ResetPasswordRepo] New password length: ${newPassword.length}',
    );
    debugPrint(
      '[ResetPasswordRepo] Confirm password length: ${confirmPassword.length}',
    );

    try {
      final response = await _apiService.post(
        '/api/v1/auth/reset-password',
        data: {
          'reset_token': resetToken,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      debugPrint('[ResetPasswordRepo] Response: $response');
      return ResetPasswordModel.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      debugPrint('[ResetPasswordRepo] Error: $e');
      rethrow;
    }
  }
}
