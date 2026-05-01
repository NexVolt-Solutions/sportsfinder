import 'dart:developer';

import 'package:sport_finding/Data/model/NotificationSettings/notification_settings_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class NotificationSettingsRepository {
  NotificationSettingsRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _preferredEndpoint = '/api/v1/users/me/settings';
  static const String _fallbackProfileEndpoint = '/api/v1/users/me';

  Future<NotificationSettingsResponseModel> updateNotificationPreference({
    required NotificationSettingsRequestModel request,
  }) async {
    final payload = request.toJson();
    final fallbackPayload = <String, dynamic>{'settings': payload};
    try {
      log(
        '[NotificationSettingsRepository] PATCH $_preferredEndpoint '
        'notifications_enabled=${request.notificationsEnabled}',
      );
      final response = await _apiService.patch(
        _preferredEndpoint,
        data: payload,
      );
      return NotificationSettingsResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );
    } catch (e, stackTrace) {
      if (!_shouldRetryWithFallback(e)) {
        log(
          '[NotificationSettingsRepository] updateNotificationPreference failed: $e',
          stackTrace: stackTrace,
        );
        rethrow;
      }
      log(
        '[NotificationSettingsRepository] Primary endpoint failed. '
        'Trying fallback PATCH $_fallbackProfileEndpoint',
      );
      try {
        final response = await _apiService.patch(
          _fallbackProfileEndpoint,
          data: payload,
        );
        return NotificationSettingsResponseModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      } catch (fallbackError, fallbackStackTrace) {
        if (!_shouldRetryWithFallback(fallbackError)) {
          log(
            '[NotificationSettingsRepository] updateNotificationPreference failed: $fallbackError',
            stackTrace: fallbackStackTrace,
          );
          rethrow;
        }
        log(
          '[NotificationSettingsRepository] Fallback root payload failed. '
          'Trying nested settings payload on $_fallbackProfileEndpoint',
        );
        final response = await _apiService.patch(
          _fallbackProfileEndpoint,
          data: fallbackPayload,
        );
        return NotificationSettingsResponseModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
    }
  }

  bool _shouldRetryWithFallback(Object error) {
    final value = error.toString().toLowerCase();
    return value.contains('not found') ||
        value.contains('failed to update data: {"detail":"not found"}') ||
        value.contains('status code: 404') ||
        value.contains('method not allowed') ||
        value.contains('status code: 405');
  }
}
