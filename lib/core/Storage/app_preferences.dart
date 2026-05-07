import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Central keys for [SharedPreferences]. Auth tokens persist across app restarts
/// and hot restarts; onboarding completion is kept across logout so setup
/// screens are one-time per install.
class AppPreferences {
  AppPreferences._();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyTokenType = 'token_type';
  static const String _keyOnboardingCompleted = 'is_onboarding_completed';
  static const String _keyPendingOnboardingSkill = 'pending_onboarding_skill';
  static const String _keyPendingOnboardingSport = 'pending_onboarding_sport';
  static const String _keyCurrentLatitude = 'current_latitude';
  static const String _keyCurrentLongitude = 'current_longitude';
  static const String _keyCurrentLocationName = 'current_location_name';
  static const String _keyLocationSearchHistory = 'location_search_history';
  static const String _keyHiddenNotificationIds = 'hidden_notification_ids';
  static const String _keyNotificationsClearedAt = 'notifications_cleared_at';
  static const String _keyChatThreadsV1 = 'chat_threads_v1';
  static const int _maxLocationSearchHistory = 12;

  /// Recent location strings from [LocationSearchScreen] (newest first).
  static Future<List<String>> getLocationSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyLocationSearchHistory) ?? <String>[];
  }

  static Future<void> addLocationSearchHistoryItem(String value) async {
    final t = value.trim();
    if (t.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    var list = List<String>.from(
      prefs.getStringList(_keyLocationSearchHistory) ?? <String>[],
    );
    list.removeWhere((e) => e == t);
    list.insert(0, t);
    if (list.length > _maxLocationSearchHistory) {
      list = list.sublist(0, _maxLocationSearchHistory);
    }
    await prefs.setStringList(_keyLocationSearchHistory, list);
  }

  static Future<void> removeLocationSearchHistoryItem(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final list = List<String>.from(
      prefs.getStringList(_keyLocationSearchHistory) ?? <String>[],
    )..removeWhere((e) => e == value);
    await prefs.setStringList(_keyLocationSearchHistory, list);
  }

  static Future<void> clearLocationSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLocationSearchHistory);
  }

  static Future<List<String>> getHiddenNotificationIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyHiddenNotificationIds) ?? <String>[];
  }

  static Future<void> setHiddenNotificationIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final cleaned = ids
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    await prefs.setStringList(_keyHiddenNotificationIds, cleaned);
  }

  static Future<void> addHiddenNotificationId(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return;
    final current = await getHiddenNotificationIds();
    if (current.contains(trimmed)) return;
    await setHiddenNotificationIds(<String>[...current, trimmed]);
  }

  static Future<void> clearHiddenNotificationIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHiddenNotificationIds);
  }

  // --- chat threads (stored locally) ---

  /// Stored as JSON string of a list of maps.
  static Future<List<Map<String, dynamic>>> getChatThreads() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyChatThreadsV1);
    if (raw == null || raw.trim().isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <Map<String, dynamic>>[];
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  static Future<void> setChatThreads(List<Map<String, dynamic>> threads) async {
    final prefs = await SharedPreferences.getInstance();
    final cleaned = threads
        .map((e) => Map<String, dynamic>.from(e))
        .where((e) => (e['userName']?.toString().trim() ?? '').isNotEmpty)
        .toList();
    await prefs.setString(_keyChatThreadsV1, jsonEncode(cleaned));
  }

  static Future<void> clearChatThreads() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyChatThreadsV1);
  }

  static Future<DateTime?> getNotificationsClearedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyNotificationsClearedAt);
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw.trim());
  }

  static Future<void> setNotificationsClearedAt(DateTime? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_keyNotificationsClearedAt);
      return;
    }
    await prefs.setString(_keyNotificationsClearedAt, value.toUtc().toIso8601String());
  }

  static Future<void> saveAuthTokens({
    required String accessToken,
    String? refreshToken,
    String? tokenType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_keyRefreshToken, refreshToken);
    }
    if (tokenType != null && tokenType.isNotEmpty) {
      await prefs.setString(_keyTokenType, tokenType);
    }
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_keyAccessToken);
    if (t == null || t.isEmpty) return null;
    return t;
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_keyRefreshToken);
    if (t == null || t.isEmpty) return null;
    return t;
  }

  static Future<bool> isLoggedIn() async {
    final t = await getAccessToken();
    return t != null && t.isNotEmpty;
  }

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, value);
  }

  static Future<void> setPendingOnboardingSkill(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPendingOnboardingSkill, value.trim());
  }

  static Future<String?> getPendingOnboardingSkill() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_keyPendingOnboardingSkill);
    if (t == null || t.trim().isEmpty) return null;
    return t.trim();
  }

  static Future<void> setPendingOnboardingSport(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPendingOnboardingSport, value.trim());
  }

  static Future<String?> getPendingOnboardingSport() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_keyPendingOnboardingSport);
    if (t == null || t.trim().isEmpty) return null;
    return t.trim();
  }

  static Future<void> clearPendingOnboardingSportSkill() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPendingOnboardingSkill);
    await prefs.remove(_keyPendingOnboardingSport);
  }

  static Future<void> saveCurrentLocation({
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyCurrentLatitude, latitude);
    await prefs.setDouble(_keyCurrentLongitude, longitude);
    if (locationName != null && locationName.trim().isNotEmpty) {
      await prefs.setString(_keyCurrentLocationName, locationName.trim());
    }
  }

  static Future<(double latitude, double longitude)?> getCurrentLocation()
  async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble(_keyCurrentLatitude);
    final longitude = prefs.getDouble(_keyCurrentLongitude);
    if (latitude == null || longitude == null) return null;
    return (latitude, longitude);
  }

  static Future<String?> getCurrentLocationText() async {
    final name = await getCurrentLocationName();
    if (name != null && name.trim().isNotEmpty) return name.trim();
    final coords = await getCurrentLocation();
    if (coords == null) return null;
    return '${coords.$1},${coords.$2}';
  }

  static Future<String?> getCurrentLocationName() async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString(_keyCurrentLocationName);
    if (text == null || text.trim().isEmpty) return null;
    return text.trim();
  }

  /// Removes auth tokens only. Keeps onboarding and other preferences.
  static Future<void> clearAuthSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyTokenType);
    await clearHiddenNotificationIds();
    await setNotificationsClearedAt(null);
    await clearPendingOnboardingSportSkill();
    await clearChatThreads();
  }
}
