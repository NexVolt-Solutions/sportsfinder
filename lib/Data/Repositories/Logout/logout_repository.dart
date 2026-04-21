import 'dart:developer';

import 'package:sport_finding/Data/model/Logout/logout_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class LogoutRepository {
  LogoutRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<LogoutResponseModel> logout({
    required LogoutRequestModel request,
  }) async {
    try {
      log('[LogoutRepository] Logout API hit started');
      final response = await _apiService.post(
        '/api/v1/auth/logout',
        data: request.toJson(),
      );
      log('[LogoutRepository] Logout API hit success: $response');
      return LogoutResponseModel.fromJson(Map<String, dynamic>.from(response));
    } catch (e, stackTrace) {
      log(
        '[LogoutRepository] Logout API hit failed: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
