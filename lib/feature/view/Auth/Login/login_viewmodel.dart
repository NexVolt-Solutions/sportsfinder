import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sport_finding/Data/Repositories/GoogleAuth/google_auth_repository.dart';
import 'package:sport_finding/Data/Repositories/login_repository.dart';
import 'package:sport_finding/Data/model/GoogleAuth/google_auth_request_model.dart';
import 'package:sport_finding/core/Constants/google_sign_in_config.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Network/fcm_service.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/utils/auth_route_resolver.dart';

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

  static String? get _resolvedWebClientId {
    if (_googleClientId.isNotEmpty) {
      return _googleClientId;
    }
    if (kGoogleOauth2WebClientId.isNotEmpty) {
      return kGoogleOauth2WebClientId;
    }
    return null;
  }

  static String? get _resolvedServerClientId {
    if (_googleServerClientId.isNotEmpty) {
      return _googleServerClientId;
    }
    if (kGoogleOauth2WebClientId.isNotEmpty) {
      return kGoogleOauth2WebClientId;
    }
    return null;
  }

  static void _logGoogle(String message) {
    debugPrint('[GoogleAuth] ${DateTime.now().toIso8601String()} $message');
  }

  /// OAuth client IDs are not secrets; still avoid dumping huge strings.
  static String _describeOAuthId(String? id) {
    if (id == null) {
      return 'null';
    }
    if (id.isEmpty) {
      return 'empty';
    }
    final tail = id.length > 24 ? '…${id.substring(id.length - 20)}' : id;
    return 'len=${id.length} $tail';
  }

  static Future<void> _ensureGoogleSignInInitialized() {
    if (_googleSignInInitialization == null) {
      _logGoogle(
        'GoogleSignIn.initialize: '
        'clientId=${_describeOAuthId(_resolvedWebClientId)} '
        'serverClientId=${_describeOAuthId(_resolvedServerClientId)} '
        '(${_googleServerClientId.isNotEmpty
            ? "GOOGLE_SERVER_CLIENT_ID"
            : kGoogleOauth2WebClientId.isNotEmpty
            ? "kGoogleOauth2WebClientId"
            : "null (use default_web_client_id from google-services if present)"})',
      );
    }
    return _googleSignInInitialization ??= GoogleSignIn.instance.initialize(
      // Web requires a `clientId` and does NOT support `serverClientId`.
      clientId: _resolvedWebClientId,
      serverClientId: kIsWeb ? null : _resolvedServerClientId,
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
      await FcmService.instance.registerTokenWithBackendIfAuthenticated();

      return AuthRouteResolver.resolvePostAuthTag();
    } catch (e) {
      return _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> loginWithGoogle() async {
    if (_isGoogleLoading) {
      _logGoogle('loginWithGoogle: skipped (already loading)');
      return null;
    }

    try {
      _isGoogleLoading = true;
      notifyListeners();
      _logGoogle('loginWithGoogle: start');

      await _ensureGoogleSignInInitialized();
      _logGoogle('loginWithGoogle: init done');

      final supportsAuth = GoogleSignIn.instance.supportsAuthenticate();
      _logGoogle('loginWithGoogle: supportsAuthenticate()=$supportsAuth');
      if (!supportsAuth) {
        _logGoogle('loginWithGoogle: early exit — not supported on platform');
        return 'Google sign-in is not supported on this platform.';
      }

      _logGoogle('loginWithGoogle: calling authenticate() with scopeHint');
      String? idToken;
      try {
        final GoogleSignInAccount account = await GoogleSignIn.instance
            .authenticate(scopeHint: const ['email', 'profile', 'openid']);
        idToken = account.authentication.idToken;
        _logGoogle(
          'loginWithGoogle: account id=${account.id} '
          'email=${account.email} '
          'idToken: ${idToken == null || idToken.isEmpty ? "MISSING" : "len=${idToken.length} (ok)"}',
        );
      } on GoogleSignInException catch (e) {
        if (e.code != GoogleSignInExceptionCode.canceled) rethrow;
        _logGoogle(
          'loginWithGoogle: authenticate() canceled; trying silent lightweight fallback',
        );
        final fallbackAccount = await GoogleSignIn.instance
            .attemptLightweightAuthentication();
        if (fallbackAccount == null) {
          _logGoogle(
            'loginWithGoogle: lightweight fallback returned null (still canceled/no cached auth)',
          );
          return _googleErrorMessage(e);
        }
        final fallbackAuth = fallbackAccount.authentication;
        idToken = fallbackAuth.idToken;
        _logGoogle(
          'loginWithGoogle: fallback account id=${fallbackAccount.id} '
          'email=${fallbackAccount.email} '
          'idToken: ${idToken == null || idToken.isEmpty ? "MISSING" : "len=${idToken.length} (ok)"}',
        );
      }

      if (idToken == null || idToken.isEmpty) {
        _logGoogle(
          'loginWithGoogle: early exit — no idToken (Check SHA-1 in Firebase, serverClientId, Play services)',
        );
        return 'Google ID token not received. Check Firebase/Google setup.';
      }

      if (kDebugMode) {
        final aud = idTokenGoogleAud(idToken);
        _logGoogle(
          'loginWithGoogle: id_token JWT aud=$aud '
          '(API must verify audience = $kGoogleIdTokenExpectedAudience)',
        );
        if (aud != null && aud != kGoogleIdTokenExpectedAudience) {
          _logGoogle(
            'loginWithGoogle: WARNING — aud != Web client id; '
            'check GoogleSignIn.initialize(serverClientId: …)',
          );
        }
      }

      _logGoogle(
        'loginWithGoogle: POST /api/v1/auth/google (idToken not logged)',
      );
      final response = await googleAuthRepository.loginWithGoogle(
        GoogleAuthRequestModel(idToken: idToken),
      );

      if (response.accessToken.isEmpty) {
        _logGoogle('loginWithGoogle: API returned empty accessToken');
        return 'Google login failed: No access token received';
      }

      _logGoogle(
        'loginWithGoogle: API ok accessToken len=${response.accessToken.length} '
        'refreshToken=${response.refreshToken == null || response.refreshToken!.isEmpty ? "empty" : "len=${response.refreshToken!.length}"}',
      );

      await _saveTokens(
        response.accessToken,
        response.refreshToken,
        response.tokenType,
      );
      await FcmService.instance.registerTokenWithBackendIfAuthenticated();

      final route = await AuthRouteResolver.resolvePostAuthTag();
      _logGoogle('loginWithGoogle: success → route=$route');
      return route;
    } on GoogleSignInException catch (e, st) {
      _logGoogle(
        'loginWithGoogle: GoogleSignInException '
        'code=${e.code} description=${e.description} runtimeType=${e.runtimeType}',
      );
      debugPrintStack(label: '[GoogleAuth] stack', stackTrace: st);
      return _googleErrorMessage(e);
    } catch (e, st) {
      _logGoogle(
        'loginWithGoogle: unhandled error type=${e.runtimeType} message=$e',
      );
      debugPrintStack(label: '[GoogleAuth] stack', stackTrace: st);
      final msg = _cleanError(e);
      if (msg.contains('audience mismatch') ||
          msg.contains('Google token audience')) {
        return 'Sign-in failed: the server rejected the Google token audience. '
            'The API must verify ID tokens using the Firebase Web client ID: '
            '$kGoogleIdTokenExpectedAudience (same as GoogleSignIn serverClientId).';
      }
      return msg;
    } finally {
      _isGoogleLoading = false;
      notifyListeners();
      _logGoogle('loginWithGoogle: finished (loading cleared)');
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

  /// When [pushTokenAlreadyDeactivated] is true, the caller already ran
  /// [FcmService.deactivateForLogout] while the access token was still valid
  /// (e.g. profile flow before `POST /auth/logout`).
  static Future<void> logout({bool pushTokenAlreadyDeactivated = false}) async {
    if (!pushTokenAlreadyDeactivated) {
      await FcmService.instance.deactivateForLogout();
    }

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
