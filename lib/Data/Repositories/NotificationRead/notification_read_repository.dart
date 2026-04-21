import 'dart:developer';

import 'package:sport_finding/Data/model/NotificationRead/notification_read_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class NotificationReadRepository {
  NotificationReadRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<NotificationReadResponseModel> markAsRead({
    required String notificationId,
  }) async {
    try {
      log(
        '[NotificationReadRepository] PATCH /api/v1/notifications/$notificationId/read',
      );
      final response = await _apiService.patch(
        '/api/v1/notifications/$notificationId/read',
      );
      return NotificationReadResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );
    } catch (e, stackTrace) {
      log(
        '[NotificationReadRepository] markAsRead failed for $notificationId: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
