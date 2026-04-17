import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/login_repository.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';

class LoginScreenViewModel extends ChangeNotifier {
  final LoginRepository repository;

  LoginScreenViewModel({required this.repository});

  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  final TextEditingController _emailController = TextEditingController();
  TextEditingController get emailController => _emailController;

  final TextEditingController _passwordController = TextEditingController();
  TextEditingController get passwordController => _passwordController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _print(String msg) => debugPrint("🔵 $msg");

  Future<String?> loginUser() async {
    _print("========== LOGIN START ==========");

    if (!(_formKey.currentState?.validate() ?? false)) {
      _print("❌ Form validation failed");
      return "Please fill all the fields";
    }

    try {
      _isLoading = true;
      notifyListeners();

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      _print("📧 Email: $email");
      _print("🔑 Password: ${'*' * password.length}");

      final response = await repository.loginUser(
        email,
        password,
        'access_token',
        'refresh_token',
        'token_type',
      );

      _print("📦 API RESPONSE:");
      _print("$response");

      final accessToken = response['accessToken'];
      final refreshToken = response['refreshToken'];
      final tokenType = response['tokenType'];

      _print("🔐 AccessToken: $accessToken");

      if (accessToken == null || accessToken.toString().isEmpty) {
        _print("❌ No access token received");
        return "Login failed: No token received";
      }

      await _saveTokens(accessToken, refreshToken, tokenType);

      final isOnboardingCompleted =
          await AppPreferences.isOnboardingCompleted();

      _print("📲 Onboarding: $isOnboardingCompleted");

      _print("========== LOGIN SUCCESS ==========");

      return isOnboardingCompleted ? "HOME" : "SKILL_LEVEL";
    } catch (e) {
      _print("❌ ERROR: $e");
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
      _print("========== LOGIN END ==========");
    }
  }

  Future<void> _saveTokens(
    String accessToken,
    String? refreshToken,
    String? tokenType,
  ) async {
    await AppPreferences.saveAuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
    );

    _print("💾 Tokens saved successfully");
  }

  static Future<String?> getAccessToken() async {
    final token = await AppPreferences.getAccessToken();
    debugPrint("🔵 TOKEN: $token");
    return token;
  }

  static Future<bool> isLoggedIn() async {
    final result = await AppPreferences.isLoggedIn();
    debugPrint("🔵 IS LOGGED IN: $result");
    return result;
  }

  static Future<void> logout() async {
    await AppPreferences.clearAuthSession();
    ProfileService().clear();
    debugPrint("🔵 USER LOGGED OUT (auth cleared; onboarding prefs kept)");
  }

  @override
  void dispose() {
    _print("Dispose ViewModel");
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
