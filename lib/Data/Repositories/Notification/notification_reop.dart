import 'dart:developer';
import 'package:sport_finding/Data/model/Notification/notification_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class NotificationRepository {
  final ApiService _apiService = ApiService();

  Future<NotificationResponseModel> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      log("📡 [Notification API] Requesting...");
      log("➡️ Endpoint: /api/v1/notifications?page=$page&limit=$limit");

      final response = await _apiService.get(
        "/api/v1/notifications?page=$page&limit=$limit",
      );

      log("✅ [Notification API] Success");
      log("📦 Response: $response");

      return NotificationResponseModel.fromJson(response);
    } catch (e, stackTrace) {
      log("❌ [Notification API] Error: $e");
      log("📛 StackTrace: $stackTrace");

      rethrow;
    }
  }
}
