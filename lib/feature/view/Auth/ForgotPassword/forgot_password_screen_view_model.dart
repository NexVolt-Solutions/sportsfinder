// import 'package:flutter/material.dart';
// import 'package:sport_finding/Data/Repositories/forgot_password_repository.dart';

// class ForgotPasswordScreenViewModel extends ChangeNotifier {
//   final ForgotPasswordRepository repository;
//   ForgotPasswordScreenViewModel({required this.repository});
//   final _formKey = GlobalKey<FormState>();
//   GlobalKey<FormState> get formKey => _formKey;

//   final TextEditingController _emailController = TextEditingController();
//   TextEditingController get emailController => _emailController;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String _errorMessage = "";
//   String get errorMessage => _errorMessage;

//   Future<String?> verfyOtp({required String email, required String otp}) async {
//     try {
//       _isLoading = true;
//       _errorMessage = "";
//       notifyListeners();
//       await repository.verifyOtp(email: email, otp: otp);
//       print(otp);
//       print(email);
//       return null;
//     } catch (e) {
//       _errorMessage = e.toString();
//       return _errorMessage;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // ✅ Resend OTP
//   Future<String?> resendOtp({required String email}) async {
//     try {
//       _isLoading = true;
//       _errorMessage = '';
//       notifyListeners();

//       await repository.resendOtp(email: email);
//       print("OTP Resent Successfully!");
//       print(email);

//       return null; // ✅ success
//     } catch (e) {
//       _errorMessage = e.toString();
//       return _errorMessage;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<String?> forgotPassword() async {
//     if (!_formKey.currentState!.validate()) {
//       return "Please fill all the fields";
//     }

//     try {
//       print(_emailController.text.trim());
//       _isLoading = true;
//       notifyListeners();
//       final response = await repository.forgotPassword(
//         _emailController.text.trim(),
//       );
//       print('response: $response');
//       if (response['status'] == 'success') {
//         print(response['data']['token']);
//         return null;
//       }
//     } catch (e) {
//       print('error: $e');
//       return e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//     return null;
//   }
// }
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/forgot_password_repository.dart';

class ForgotPasswordScreenViewModel extends ChangeNotifier {
  final ForgotPasswordRepository repository;

  ForgotPasswordScreenViewModel({required this.repository});

  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  final TextEditingController _emailController = TextEditingController();
  TextEditingController get emailController => _emailController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ✅ Send forgot password OTP
  Future<String?> forgotPassword() async {
    if (!_formKey.currentState!.validate()) {
      return 'Please enter your email';
    }

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      return 'Please enter your email';
    }

    try {
      _isLoading = true;
      notifyListeners();

      final response = await repository.forgotPassword(email);

      // ✅ API returns message on success
      if (response['message'] != null) {
        return null; // success
      }

      return response['message'] ?? 'Something went wrong';
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ FIXED: Resend OTP — calls forgot-password endpoint again
  Future<String?> resendOtp({required String email}) async {
    if (email.isEmpty) {
      return 'Email is required';
    }

    try {
      _isLoading = true;
      notifyListeners();

      // ✅ Calls forgot-password again to resend OTP
      final response = await repository.resendOtp(email: email);

      if (response['message'] != null) {
        return null; // success
      }

      return response['message'] ?? 'Failed to resend OTP';
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Verify OTP
  Future<String?> verifyOtp({
    required String email,
    required String otp,
  }) async {
    if (email.isEmpty) return 'Email is required';
    if (otp.isEmpty || otp.length != 6) return 'Please enter valid 6-digit OTP';

    try {
      _isLoading = true;
      notifyListeners();

      final response = await repository.verifyOtp(email: email, otp: otp);

      if (response['message'] != null) {
        return null; // success
      }

      return response['message'] ?? 'Verification failed';
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
