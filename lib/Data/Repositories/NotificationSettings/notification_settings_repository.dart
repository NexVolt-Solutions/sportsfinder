import 'dart:developer';

import 'package:sport_finding/Data/model/NotificationSettings/notification_settings_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class NotificationSettingsRepository {
  NotificationSettingsRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _preferredEndpoint = '/api/v1/users/me/settings';
  static const String _profileEndpoint = '/api/v1/users/me';

  Future<NotificationSettingsResponseModel> updateNotificationPreference({
    required NotificationSettingsRequestModel request,
  }) async {
    final payload = request.toJson();
    final fallbackPayload = <String, dynamic>{'settings': payload};
    try {
      log(
        '[NotificationSettingsRepository] PUT $_profileEndpoint '
        'notifications_enabled=${request.notificationsEnabled}',
      );
      final response = await _apiService.put(_profileEndpoint, data: payload);
      return NotificationSettingsResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );
    } catch (e, stackTrace) {
      if (!_shouldRetryWithFallback(e)) {
        log(
          '[NotificationSettingsRepository] PUT $_profileEndpoint failed: $e',
          stackTrace: stackTrace,
        );
        rethrow;
      }
      log(
        '[NotificationSettingsRepository] PUT failed. '
        'Trying PATCH $_preferredEndpoint',
      );
    }
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
        '[NotificationSettingsRepository] Primary PATCH failed. '
        'Trying fallback PATCH $_profileEndpoint',
      );
      try {
        final response = await _apiService.patch(
          _profileEndpoint,
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
          'Trying nested settings payload on $_profileEndpoint',
        );
        final response = await _apiService.patch(
          _profileEndpoint,
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
