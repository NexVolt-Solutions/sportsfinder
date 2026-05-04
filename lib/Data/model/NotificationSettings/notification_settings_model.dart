class NotificationSettingsRequestModel {
  final bool notificationsEnabled;

  NotificationSettingsRequestModel({required this.notificationsEnabled});

  Map<String, dynamic> toJson() {
    return {'notifications_enabled': notificationsEnabled};
  }
}

class NotificationSettingsResponseModel {
  final String message;
  final bool? notificationsEnabled;

  NotificationSettingsResponseModel({
    required this.message,
    this.notificationsEnabled,
  });

  factory NotificationSettingsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'];
    final settingsRaw = json['settings'];
    bool? enabled;
    if (json['notifications_enabled'] is bool) {
      enabled = json['notifications_enabled'] as bool;
    } else if (data is Map && data['notifications_enabled'] is bool) {
      enabled = data['notifications_enabled'] as bool;
    } else if (settingsRaw is Map &&
        settingsRaw['notifications_enabled'] is bool) {
      enabled = settingsRaw['notifications_enabled'] as bool;
    }

    final message = (json['message'] ?? json['detail'] ?? '').toString();

    return NotificationSettingsResponseModel(
      message: message,
      notificationsEnabled: enabled,
    );
  }
}
