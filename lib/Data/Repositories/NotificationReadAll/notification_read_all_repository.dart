import 'dart:developer';

import 'package:sport_finding/Data/model/NotificationReadAll/notification_read_all_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class NotificationReadAllRepository {
  NotificationReadAllRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<NotificationReadAllResponseModel> markAllAsRead() async {
    try {
      log('[NotificationReadAllRepository] PATCH /api/v1/notifications/read-all');
      final response = await _apiService.patch('/api/v1/notifications/read-all');
      return NotificationReadAllResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );
    } catch (e, stackTrace) {
      log(
        '[NotificationReadAllRepository] markAllAsRead failed: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
