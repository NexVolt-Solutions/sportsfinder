import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/Notification/notification_reop.dart';
import 'package:sport_finding/Data/model/Notification/notification_model.dart';

class NotificationService extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();

  List<NotificationModel> notifications = [];
  bool isLoading = false;

  Future<void> fetchNotifications() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _repo.getNotifications();
      notifications = response.items;
    } catch (e) {
      print("❌ Notification Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
