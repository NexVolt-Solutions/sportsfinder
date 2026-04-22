import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sport_finding/Data/Repositories/GoogleAuth/google_auth_repository.dart';
import 'package:sport_finding/Data/Repositories/login_repository.dart';
import 'package:sport_finding/Data/model/GoogleAuth/google_auth_request_model.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';

class LoginScreenViewModel extends ChangeNotifier {
  LoginScreenViewModel({
    required this.repository,
    required this.googleAuthRepository,
  });

  final LoginRepository repository;
  final GoogleAuthRepository googleAuthRepository;

  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  final TextEditingController _emailController = TextEditingController();
  TextEditingController get emailController => _emailController;

  final TextEditingController _passwordController = TextEditingController();
  TextEditingController get passwordController => _passwordController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isGoogleLoading = false;
  bool get isGoogleLoading => _isGoogleLoading;

  static Future<void>? _googleSignInInitialization;
  static const String _googleClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
  static const String _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  static Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInitialization ??= GoogleSignIn.instance.initialize(
      clientId: _googleClientId.isEmpty ? null : _googleClientId,
      serverClientId:
          _googleServerClientId.isEmpty ? null : _googleServerClientId,
    );
  }

  Future<String?> loginUser() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return 'Please fill all the fields';
    }

    try {
      _isLoading = true;
      notifyListeners();

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final response = await repository.loginUser(
        email,
        password,
        'access_token',
        'refresh_token',
        'token_type',
      );

      final accessToken = response['accessToken'];
      final refreshToken = response['refreshToken'];
      final tokenType = response['tokenType'];

      if (accessToken == null || accessToken.toString().isEmpty) {
        return 'Login failed: No token received';
      }

      await _saveTokens(accessToken, refreshToken, tokenType);

      final isOnboardingCompleted =
          await AppPreferences.isOnboardingCompleted();
      return isOnboardingCompleted ? 'HOME' : 'SKILL_LEVEL';
    } catch (e) {
      return _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> loginWithGoogle() async {
    if (_isGoogleLoading) {
      return null;
    }

    try {
      _isGoogleLoading = true;
      notifyListeners();

      await _ensureGoogleSignInInitialized();

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        return 'Google sign-in is not supported on this platform.';
      }

      final GoogleSignInAccount account =
          await GoogleSignIn.instance.authenticate();
      final String? idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        return 'Google ID token not received. Check Firebase/Google setup.';
      }

      final response = await googleAuthRepository.loginWithGoogle(
        GoogleAuthRequestModel(idToken: idToken),
      );

      if (response.accessToken.isEmpty) {
        return 'Google login failed: No access token received';
      }

      await _saveTokens(
        response.accessToken,
        response.refreshToken,
        response.tokenType,
      );

      final isOnboardingCompleted =
          await AppPreferences.isOnboardingCompleted();
      return isOnboardingCompleted ? 'HOME' : 'SKILL_LEVEL';
    } on GoogleSignInException catch (e) {
      return _googleErrorMessage(e);
    } catch (e) {
      return _cleanError(e);
    } finally {
      _isGoogleLoading = false;
      notifyListeners();
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
  }

  static Future<String?> getAccessToken() async {
    return AppPreferences.getAccessToken();
  }

  static Future<bool> isLoggedIn() async {
    return AppPreferences.isLoggedIn();
  }

  static Future<void> logout() async {
    try {
      await _ensureGoogleSignInInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    await AppPreferences.clearAuthSession();
    ProfileService().clear();
    debugPrint('USER LOGGED OUT (auth cleared; onboarding prefs kept)');
  }

  String _googleErrorMessage(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Google sign-in was canceled.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Google sign-in configuration is invalid. Check Firebase setup.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google sign-in UI is unavailable right now.';
      default:
        return error.description ?? 'Google sign-in failed.';
    }
  }

  String _cleanError(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
