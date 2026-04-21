import 'package:shared_preferences/shared_preferences.dart';

/// Central keys for [SharedPreferences]. Auth tokens persist across app restarts
/// and hot restarts; onboarding completion is kept across logout so setup
/// screens are one-time per install.
class AppPreferences {
  AppPreferences._();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyTokenType = 'token_type';
  static const String _keyOnboardingCompleted = 'is_onboarding_completed';
  static const String _keyCurrentLatitude = 'current_latitude';
  static const String _keyCurrentLongitude = 'current_longitude';
  static const String _keyCurrentLocationName = 'current_location_name';

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
  }
}
