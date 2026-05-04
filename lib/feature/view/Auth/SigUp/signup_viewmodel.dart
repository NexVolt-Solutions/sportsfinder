// import 'package:flutter/foundation.dart'; // ✅ ADD THIS for kIsWeb
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:sport_finding/Data/Repositories/sign_up_repository.dart';

// class SignUpViewModel extends ChangeNotifier {
//   final SignUpRepository repository;
//   final ImagePicker _imagePicker;

//   SignUpViewModel({required this.repository, ImagePicker? imagePicker})
//     : _imagePicker = imagePicker ?? ImagePicker();

//   final _formKey = GlobalKey<FormState>();
//   GlobalKey<FormState> get formKey => _formKey;

//   final TextEditingController _fullNameController = TextEditingController();
//   TextEditingController get fullNameController => _fullNameController;

//   final TextEditingController _emailController = TextEditingController();
//   TextEditingController get emailController => _emailController;

//   final TextEditingController _passwordController = TextEditingController();
//   TextEditingController get passwordController => _passwordController;

//   final TextEditingController _confirmPasswordController =
//       TextEditingController();
//   TextEditingController get confirmPasswordController =>
//       _confirmPasswordController;

//   String? _profileImagePath;
//   List<int>? _profileImageBytes;
//   String? _profileImageName;

//   XFile? _pickedXFile;
//   XFile? get pickedXFile => _pickedXFile;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   Future<String?> pickProfileImageFromGallery() async {
//     try {
//       final file = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );

//       if (file == null) return null;

//       _pickedXFile = file; // ✅ store XFile for UI preview

//       if (kIsWeb) {
//         // ✅ Web: read bytes
//         _profileImageBytes = await file.readAsBytes();
//         _profileImageName = file.name;
//         _profileImagePath = null;
//       } else {
//         // ✅ Mobile: use path
//         _profileImagePath = file.path;
//         _profileImageBytes = null;
//         _profileImageName = null;
//       }

//       notifyListeners();
//       return null;
//     } catch (e) {
//       return "Failed to pick image: $e";
//     }
//   }

//   Future<String?> registerUser() async {
//     if (!_formKey.currentState!.validate()) {
//       return "Please fill all fields correctly";
//     }

//     if (_passwordController.text != _confirmPasswordController.text) {
//       return "Passwords do not match";
//     }

//     try {
//       _isLoading = true;
//       notifyListeners();

//       await repository.signUpUser(
//         fullName: _fullNameController.text.trim(),
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//         confirmPassword: _confirmPasswordController.text.trim(),
//         acceptTerms: true,
//         imagePath: kIsWeb ? null : _profileImagePath, // 📱 Mobile
//         imageBytes: kIsWeb ? _profileImageBytes : null, // 🌐 Web
//         imageName: kIsWeb ? _profileImageName : null, // 🌐 Web
//       );

//       return null;
//     } catch (e) {
//       return e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_finding/Data/Repositories/GoogleAuth/google_auth_repository.dart';
import 'package:sport_finding/Data/model/GoogleAuth/google_auth_request_model.dart';
import 'package:sport_finding/Data/Repositories/sign_up_repository.dart';
import 'package:sport_finding/core/Constants/google_sign_in_config.dart';
import 'package:sport_finding/core/Network/fcm_service.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/utils/auth_route_resolver.dart';

class SignUpViewModel extends ChangeNotifier {
  final SignUpRepository repository;
  final GoogleAuthRepository googleAuthRepository;
  final ImagePicker _imagePicker;

  SignUpViewModel({
    required this.repository,
    required this.googleAuthRepository,
    ImagePicker? imagePicker,
  })
    : _imagePicker = imagePicker ?? ImagePicker();

  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  final TextEditingController _fullNameController = TextEditingController();
  TextEditingController get fullNameController => _fullNameController;

  final TextEditingController _emailController = TextEditingController();
  TextEditingController get emailController => _emailController;

  final TextEditingController _passwordController = TextEditingController();
  TextEditingController get passwordController => _passwordController;

  final TextEditingController _confirmPasswordController =
      TextEditingController();
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;

  String? _profileImagePath;
  List<int>? _profileImageBytes;
  String? _profileImageName;

  XFile? _pickedXFile;
  XFile? get pickedXFile => _pickedXFile;

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

  static String? get _resolvedServerClientId {
    if (_googleServerClientId.isNotEmpty) return _googleServerClientId;
    if (kGoogleOauth2WebClientId.isNotEmpty) return kGoogleOauth2WebClientId;
    return null;
  }

  static Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInitialization ??= GoogleSignIn.instance.initialize(
      clientId: _googleClientId.isEmpty ? null : _googleClientId,
      serverClientId: _resolvedServerClientId,
    );
  }

  Future<String?> pickProfileImageFromGallery() async {
    try {
      _log("Picking profile image from gallery...");

      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file == null) {
        _log("No image selected");
        return null;
      }

      _pickedXFile = file;

      if (kIsWeb) {
        _log("Platform: Web");
        _profileImageBytes = await file.readAsBytes();
        _profileImageName = file.name;
        _profileImagePath = null;

        _log("Image Name: ${file.name}");
        _log("Image Bytes Size: ${_profileImageBytes?.length}");
      } else {
        _log("Platform: Mobile");
        _profileImagePath = file.path;
        _profileImageBytes = null;
        _profileImageName = null;

        _log("Image Path: ${file.path}");
      }

      notifyListeners();
      return null;
    } catch (e, stackTrace) {
      _log("Error picking image: $e");
      _log("StackTrace: $stackTrace");
      return "Failed to pick image: $e";
    }
  }

  Future<String?> registerUser() async {
    _log("========== SIGNUP PROCESS STARTED ==========");

    if (!_formKey.currentState!.validate()) {
      _log("Form validation failed");
      return "Please fill all fields correctly";
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _log("Password mismatch detected");
      return "Passwords do not match";
    }

    try {
      _isLoading = true;
      notifyListeners();

      _log("Calling SignUp API...");
      _log("Full Name: ${_fullNameController.text.trim()}");
      _log("Email: ${_emailController.text.trim()}");
      _log("Accept Terms: true");

      await repository.signUpUser(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
        acceptTerms: true,
        imagePath: kIsWeb ? null : _profileImagePath,
        imageBytes: kIsWeb ? _profileImageBytes : null,
        imageName: kIsWeb ? _profileImageName : null,
      );

      _log("SignUp API completed successfully");

      return null;
    } catch (e, stackTrace) {
      _log("SignUp Error: $e");
      _log("StackTrace: $stackTrace");
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
      _log("========== SIGNUP PROCESS ENDED ==========");
    }
  }

  Future<String?> loginWithGoogle() async {
    if (_isGoogleLoading) return null;
    try {
      _isGoogleLoading = true;
      notifyListeners();

      await _ensureGoogleSignInInitialized();
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        return 'Google sign-in is not supported on this platform.';
      }

      String? idToken;
      try {
        final account = await GoogleSignIn.instance.authenticate(
          scopeHint: const ['email', 'profile', 'openid'],
        );
        idToken = account.authentication.idToken;
      } on GoogleSignInException catch (e) {
        if (e.code != GoogleSignInExceptionCode.canceled) rethrow;
        final fallback = await GoogleSignIn.instance
            .attemptLightweightAuthentication();
        if (fallback == null) {
          return 'Google sign-in was canceled.';
        }
        idToken = fallback.authentication.idToken;
      }

      if (idToken == null || idToken.isEmpty) {
        return 'Google ID token not received. Check Firebase/Google setup.';
      }

      final response = await googleAuthRepository.loginWithGoogle(
        GoogleAuthRequestModel(idToken: idToken),
      );
      if (response.accessToken.isEmpty) {
        return 'Google login failed: No access token received';
      }

      await AppPreferences.saveAuthTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        tokenType: response.tokenType,
      );
      await FcmService.instance.registerTokenWithBackendIfAuthenticated();
      return AuthRouteResolver.resolvePostAuthTag();
    } on GoogleSignInException catch (e) {
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
          return 'Google sign-in was canceled.';
        case GoogleSignInExceptionCode.clientConfigurationError:
          return 'Google sign-in configuration is invalid. Check Firebase setup.';
        case GoogleSignInExceptionCode.uiUnavailable:
          return 'Google sign-in UI is unavailable right now.';
        default:
          return e.description ?? 'Google sign-in failed.';
      }
    } catch (e) {
      final m = e.toString();
      return m.startsWith('Exception: ') ? m.substring(11) : m;
    } finally {
      _isGoogleLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _log("Disposing SignUpViewModel");

    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }
}
