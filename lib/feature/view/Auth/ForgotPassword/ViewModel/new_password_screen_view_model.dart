// // // import 'package:flutter/material.dart';

// // // class NewPasswordScreenViewModel extends ChangeNotifier {
// // //   final formKey = GlobalKey<FormState>();
// // //   final passwordController = TextEditingController();
// // //   final confirmPasswordController = TextEditingController();

// // //   // bool _isLoading = false;
// // //   // bool get isLoading => _isLoading;

// // //   // Future<String?> newPassword() async {
// // //   //   if (!formKey.currentState!.validate()) {
// // //   //     return "Please fill all the fields";
// // //   //   }

// // //   //   try {
// // //   //     _isLoading = true;
// // //   //     notifyListeners();
// // //   //     final response = await repository.newPassword(
// // //   //       passwordController.text.trim(),
// // //   //       confirmPasswordController.text.trim(),
// // //   //     );
// // //   //     print('response: $response');
// // //   //     if (response['status'] == 'success') {
// // //   //       print(response['data']['token']);
// // //   //       return null;
// // //   //     }
// // //   //   } catch (e) {
// // //   //     print('error: $e');
// // //   //     return e.toString();
// // //   //   } finally {
// // //   //     _isLoading = false;
// // //   //     notifyListeners();
// // //   //   }
// // //   //   return null;
// // //   // }
// // // }
// // import 'package:flutter/material.dart';

// // class NewPasswordScreenViewModel extends ChangeNotifier {
// //   final formKey = GlobalKey<FormState>();
// //   final passwordController = TextEditingController();
// //   final confirmPasswordController = TextEditingController();

// //   bool _isLoading = false;
// //   bool get isLoading => _isLoading;

// //   void _setLoading(bool value) {
// //     _isLoading = value;
// //     notifyListeners();
// //   }

// //   Future<String?> setNewPassword() async {
// //     if (!(formKey.currentState?.validate() ?? false)) {
// //       return "Please fill all the fields";
// //     }

// //     if (passwordController.text.trim() !=
// //         confirmPasswordController.text.trim()) {
// //       return "Passwords do not match";
// //     }

// //     try {
// //       _setLoading(true);

// //       // TODO: Call reset password API here
// //       await Future.delayed(const Duration(seconds: 1));

// //       return null;
// //     } catch (e) {
// //       return e.toString();
// //     } finally {
// //       _setLoading(false);
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     passwordController.dispose();
// //     confirmPasswordController.dispose();
// //     super.dispose();
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:sport_finding/Data/Repositories/forgot_password_repository.dart';
// import 'package:sport_finding/core/Network/api_service.dart';

// class NewPasswordScreenViewModel extends ChangeNotifier {
//   final ForgotPasswordRepository repository = ForgotPasswordRepository(
//     apiService: ApiService(),
//   );
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController =
//       TextEditingController();

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }

//   /// 🔐 Reset Password Function
//   Future<String?> resetPassword() async {
//     debugPrint("🔹 Reset Password Function Called");

//     if (!(formKey.currentState?.validate() ?? false)) {
//       debugPrint("❌ Validation Failed");
//       return "Please fill all the fields";
//     }

//     final password = passwordController.text.trim();
//     final confirmPassword = confirmPasswordController.text.trim();

//     debugPrint("🔐 Password Entered: $password");
//     debugPrint("🔐 Confirm Password Entered: $confirmPassword");

//     if (password != confirmPassword) {
//       debugPrint("❌ Passwords do not match");
//       return "Passwords do not match";
//     }

//     try {
//       _setLoading(true);
//       debugPrint("⏳ Processing password reset...");

//       await Future.delayed(const Duration(seconds: 2));

//       final response = await repository.resetPassword(
//         password: password,
//         confirmPassword: confirmPassword,
//       );

//       debugPrint("✅ Password reset successfully");
//       return response['message'] ?? "Password reset successfully";
//     } catch (e) {
//       debugPrint("❌ Reset Password Error: $e");
//       return e.toString().replaceAll('Exception:', '');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   @override
//   void dispose() {
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/forgot_password_repository.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class NewPasswordScreenViewModel extends ChangeNotifier {
  final ForgotPasswordRepository repository = ForgotPasswordRepository(
    apiService: ApiService(),
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ✅ Store reset token received from OTP screen
  String _resetToken = "";

  void setResetToken(String token) {
    debugPrint("🔑 [NewPasswordVM] setResetToken called");
    debugPrint(
      "🔑 [NewPasswordVM] Token received: ${token.isNotEmpty ? '${token.substring(0, 20)}...' : 'EMPTY'}",
    );
    _resetToken = token;
  }

  void _setLoading(bool value) {
    debugPrint("⏳ [NewPasswordVM] Loading state changed: $value");
    _isLoading = value;
    notifyListeners();
  }

  /// Reset Password Function
  Future<String?> resetPassword() async {
    debugPrint("🔵 [NewPasswordVM] ─────────────────────────────────");
    debugPrint("🔵 [NewPasswordVM] resetPassword() called");
    debugPrint("🔵 [NewPasswordVM] ─────────────────────────────────");

    // ─── Form Validation ──────────────────────────────────────
    if (!(formKey.currentState?.validate() ?? false)) {
      return "Please fill all the fields";
    }

    // ─── Reset Token Check ────────────────────────────────────
    if (_resetToken.isEmpty) {
      return "Session expired. Please restart the password reset process.";
    }

    // ─── Password Match Check ─────────────────────────────────
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    debugPrint("🔐 [NewPasswordVM] Password length: ${password.length}");
    debugPrint(
      "🔐 [NewPasswordVM] Confirm password length: ${confirmPassword.length}",
    );

    if (password != confirmPassword) {
      debugPrint("❌ [NewPasswordVM] Passwords do not match");
      return "Passwords do not match";
    }
    debugPrint("✅ [NewPasswordVM] Passwords match");

    // ─── API Call ─────────────────────────────────────────────
    try {
      _setLoading(true);
      debugPrint("📤 [NewPasswordVM] Calling resetPassword API...");
      debugPrint(
        "📤 [NewPasswordVM] Endpoint: POST /api/v1/auth/reset-password",
      );
      debugPrint(
        "📤 [NewPasswordVM] Payload: reset_token=***, new_password=***, confirm_password=***",
      );

      final response = await repository.resetPassword(
        resetToken: _resetToken,
        password: password,
        confirmPassword: confirmPassword,
      );

      debugPrint("✅ [NewPasswordVM] API call successful");
      debugPrint("📥 [NewPasswordVM] Response: $response");

      final message = response['message'] ?? "Password reset successfully";
      debugPrint("✅ [NewPasswordVM] Message: $message");
      return message;
    } catch (e) {
      debugPrint("❌ [NewPasswordVM] API call failed");
      debugPrint("❌ [NewPasswordVM] Error: $e");
      return e.toString().replaceAll('Exception:', '').trim();
    } finally {
      _setLoading(false);
      debugPrint("🔵 [NewPasswordVM] resetPassword() completed");
      debugPrint("🔵 [NewPasswordVM] ─────────────────────────────────");
    }
  }

  @override
  void dispose() {
    debugPrint("🗑️ [NewPasswordVM] Disposing controllers");
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
