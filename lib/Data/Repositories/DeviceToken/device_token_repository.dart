import 'dart:developer';

import 'package:sport_finding/Data/model/DeviceToken/device_token_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/utils/network_errors.dart';

class DeviceTokenRepository {
  DeviceTokenRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  static const String _preferredEndpoint = '/api/v1/users/me/devices';
  static const String _fallbackEndpoint = '/api/v1/users/me/device-token';

  Future<DeviceTokenResponseModel> registerDeviceToken({
    required DeviceTokenRequestModel request,
  }) async {
    final payload = request.toJson();
    try {
      log(
        '[DeviceTokenRepository] POST $_preferredEndpoint '
        'platform=${request.platform}',
      );
      final response = await _apiService.post(_preferredEndpoint, data: payload);
      return DeviceTokenResponseModel.fromJson(Map<String, dynamic>.from(response));
    } catch (e, stackTrace) {
      if (!_shouldRetryWithFallback(e)) {
        if (isTransientNetworkError(e)) {
          log(
            '[DeviceTokenRepository] registerDeviceToken failed (transient network): $e',
          );
        } else {
          log(
            '[DeviceTokenRepository] registerDeviceToken failed: $e',
            stackTrace: stackTrace,
          );
        }
        rethrow;
      }
      log(
        '[DeviceTokenRepository] Preferred endpoint failed. '
        'Trying fallback POST $_fallbackEndpoint',
      );
      final response = await _apiService.post(_fallbackEndpoint, data: payload);
      return DeviceTokenResponseModel.fromJson(Map<String, dynamic>.from(response));
    }
  }

  /// `DELETE /api/v1/users/me/devices` — pass [fcmToken] to drop one device, or
  /// omit / null / empty to deactivate all tokens for the user (`{}`).
  Future<DeviceTokenResponseModel> deactivateDeviceToken({String? fcmToken}) async {
    final Map<String, dynamic> body = (fcmToken != null && fcmToken.trim().isNotEmpty)
        ? <String, dynamic>{'fcm_token': fcmToken.trim()}
        : <String, dynamic>{};
    try {
      log('[DeviceTokenRepository] DELETE $_preferredEndpoint (single=${body.isNotEmpty})');
      final response = await _apiService.delete(_preferredEndpoint, data: body);
      if (response == null) {
        return DeviceTokenResponseModel(message: 'Device token(s) deactivated successfully.');
      }
      return DeviceTokenResponseModel.fromJson(Map<String, dynamic>.from(response));
    } catch (e, stackTrace) {
      if (!_shouldRetryWithFallback(e)) {
        log(
          '[DeviceTokenRepository] deactivateDeviceToken failed: $e',
          stackTrace: stackTrace,
        );
        rethrow;
      }
      log(
        '[DeviceTokenRepository] Preferred DELETE failed. '
        'Trying fallback DELETE $_fallbackEndpoint',
      );
      final response = await _apiService.delete(_fallbackEndpoint, data: body);
      if (response == null) {
        return DeviceTokenResponseModel(message: 'Device token(s) deactivated successfully.');
      }
      return DeviceTokenResponseModel.fromJson(Map<String, dynamic>.from(response));
    }
  }

  bool _shouldRetryWithFallback(Object error) {
    final value = error.toString().toLowerCase();
    return value.contains('not found') ||
        value.contains('status code: 404') ||
        value.contains('method not allowed') ||
        value.contains('status code: 405');
  }
}
