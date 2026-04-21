import 'dart:developer';

import 'package:sport_finding/Data/model/NotificationSettings/notification_settings_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class NotificationSettingsRepository {
  NotificationSettingsRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<NotificationSettingsResponseModel> updateNotificationPreference({
    required NotificationSettingsRequestModel request,
  }) async {
    try {
      log(
        '[NotificationSettingsRepository] PATCH /api/v1/users/me/settings '
        'notifications_enabled=${request.notificationsEnabled}',
      );
      final response = await _apiService.patch(
        '/api/v1/users/me/settings',
        data: request.toJson(),
      );
      return NotificationSettingsResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );
    } catch (e, stackTrace) {
      log(
        '[NotificationSettingsRepository] updateNotificationPreference failed: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
