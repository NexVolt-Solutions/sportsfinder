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

  /// Removes auth tokens only. Keeps onboarding and other preferences.
  static Future<void> clearAuthSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyTokenType);
  }
}
