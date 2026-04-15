import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_finding/Data/Repositories/login_repository.dart';

class LoginScreenViewModel extends ChangeNotifier {
  final LoginRepository repository;

  // ✅ Make repository REQUIRED
  LoginScreenViewModel({required this.repository});

  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  final TextEditingController _emailController = TextEditingController();
  TextEditingController get emailController => _emailController;

  final TextEditingController _passwordController = TextEditingController();
  TextEditingController get passwordController => _passwordController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String?> loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return "Please fill all the fields";
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Call login API
      final response = await repository.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        'access_token',
        'refresh_token',
        'token_type',
      );

      // Extract tokens from response
      final accessToken = response['accessToken'] as String?;
      final refreshToken = response['refreshToken'] as String?;
      final tokenType = response['tokenType'] as String?;

      if (accessToken == null || accessToken.isEmpty) {
        return "No access token received from server";
      }

      // Store tokens in SharedPreferences
      await _saveTokens(accessToken, refreshToken, tokenType);

      return null;
    } catch (e) {
      return "Login failed: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Store authentication tokens in SharedPreferences
  Future<void> _saveTokens(
    String accessToken,
    String? refreshToken,
    String? tokenType,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('access_token', accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await prefs.setString('refresh_token', refreshToken);
      }
      if (tokenType != null && tokenType.isNotEmpty) {
        await prefs.setString('token_type', tokenType);
      }

      // Store login timestamp
      await prefs.setInt('login_time', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieve access token from SharedPreferences
  static Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Logout - Clear all stored tokens
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('token_type');
      await prefs.remove('login_time');
    } catch (e) {
      // Handle logout error silently
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
