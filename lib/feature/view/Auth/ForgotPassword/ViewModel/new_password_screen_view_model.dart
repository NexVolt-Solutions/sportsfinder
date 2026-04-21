import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/forgot_password_repository.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class NewPasswordScreenViewModel extends ChangeNotifier {
  NewPasswordScreenViewModel()
    : repository = ForgotPasswordRepository(apiService: ApiService());

  final ForgotPasswordRepository repository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _resetToken = '';
  String get resetToken => _resetToken;

  void setResetToken(String token) {
    _resetToken = token.trim();
    debugPrint(
      '[NewPasswordVM] reset token bound: ${_resetToken.isNotEmpty}',
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String?> resetPassword() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return 'Please fill all the fields';
    }

    if (_resetToken.isEmpty) {
      return 'Session expired. Please restart the password reset process.';
    }

    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    try {
      _setLoading(true);

      final response = await repository.resetPassword(
        resetToken: _resetToken,
        password: password,
        confirmPassword: confirmPassword,
      );

      debugPrint('[NewPasswordVM] reset password response: $response');
      passwordController.clear();
      confirmPasswordController.clear();
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception:', '').trim();
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
