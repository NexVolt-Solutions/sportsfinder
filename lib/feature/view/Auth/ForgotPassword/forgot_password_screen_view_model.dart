// import 'package:flutter/material.dart';
// import 'package:sport_finding/Data/Repositories/forgot_password_repository.dart';

// class ForgotPasswordScreenViewModel extends ChangeNotifier {
//   final ForgotPasswordRepository repository;

//   ForgotPasswordScreenViewModel({required this.repository});

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   GlobalKey<FormState> get formKey => _formKey;

//   final TextEditingController _emailController = TextEditingController();
//   TextEditingController get emailController => _emailController;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }

//   String _extractMessage(dynamic response) {
//     if (response is Map<String, dynamic>) {
//       return response['message']?.toString() ?? 'Something went wrong';
//     }
//     return 'Invalid response';
//   }

//   // ================= FORGOT PASSWORD =================
//   Future<String?> forgotPassword() async {
//     if (!(_formKey.currentState?.validate() ?? false)) {
//       return 'Please enter your email';
//     }

//     final email = _emailController.text.trim();

//     if (email.isEmpty) return 'Please enter your email';

//     try {
//       _setLoading(true);

//       final response = await repository.forgotPassword(email);

//       print("FORGOT PASSWORD RESPONSE: $response");

//       final message = _extractMessage(response);

//       return message.contains('success') ? null : message;
//     } catch (e) {
//       print("FORGOT PASSWORD ERROR: $e");
//       return e.toString().replaceAll('Exception:', '');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // ================= RESEND OTP =================
//   Future<String?> resendOtp({required String email}) async {
//     if (email.isEmpty) return 'Email is required';

//     try {
//       _setLoading(true);

//       final response = await repository.resendOtp(email: email);

//       print("RESEND OTP RESPONSE: $response");

//       final message = _extractMessage(response);

//       return message.contains('success') ? null : message;
//     } catch (e) {
//       print("RESEND OTP ERROR: $e");
//       return e.toString().replaceAll('Exception:', '');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // ================= VERIFY OTP =================
//   // Future<String?> verifyOtp({
//   //   required String email,
//   //   required String otp,
//   // }) async {
//   //   if (email.isEmpty) return 'Email is required';
//   //   if (otp.isEmpty || otp.length != 6) return 'Enter valid 6-digit OTP';

//   //   try {
//   //     _setLoading(true);

//   //     final response = await repository.verifyOtp(email: email, otp: otp);

//   //     print("VERIFY OTP RESPONSE: $response");

//   //     final message = _extractMessage(response);

//   //     return message.contains('success') ? null : message;
//   //   } catch (e) {
//   //     print("VERIFY OTP ERROR: $e");
//   //     return e.toString().replaceAll('Exception:', '');
//   //   } finally {
//   //     _setLoading(false);
//   //   }
//   // }
//   Future<String?> verifyOtp({
//     required String email,
//     required String otp,
//   }) async {
//     if (email.isEmpty) return 'Email is required';
//     if (otp.isEmpty || otp.length != 6) {
//       return 'Enter valid 6-digit OTP';
//     }

//     try {
//       _setLoading(true);

//       final response = await repository.verifyOtp(email: email, otp: otp);

//       print("VERIFY OTP RESPONSE: $response");

//       final message = _extractMessage(response).toLowerCase();

//       // Accept different success variations
//       if (message.contains('success') ||
//           message.contains('verified') ||
//           message.contains('otp verified')) {
//         return null; // Success
//       }

//       return _extractMessage(response);
//     } catch (e) {
//       print("VERIFY OTP ERROR: $e");
//       return e.toString().replaceAll('Exception:', '');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/forgot_password_repository.dart';

class ForgotPasswordScreenViewModel extends ChangeNotifier {
  final ForgotPasswordRepository repository;

  ForgotPasswordScreenViewModel({required this.repository});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _extractMessage(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response['message']?.toString() ?? 'Something went wrong';
    }
    return 'Invalid response';
  }

  bool _isSuccess(dynamic response) {
    if (response is Map<String, dynamic>) {
      final message = response['message']?.toString().toLowerCase() ?? '';
      return response['success'] == true ||
          response['status'] == true ||
          response['status'] == 200 ||
          message.contains('success') ||
          message.contains('otp') ||
          message.contains('sent');
    }
    return false;
  }

  Future<String?> forgotPassword() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return 'Please enter a valid email';
    }

    final email = emailController.text.trim();
    if (email.isEmpty) return 'Please enter your email';

    try {
      _setLoading(true);

      final response = await repository.forgotPassword(email);
      debugPrint("FORGOT PASSWORD RESPONSE: $response");

      return _isSuccess(response) ? null : _extractMessage(response);
    } catch (e) {
      return e.toString().replaceAll('Exception:', '');
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
