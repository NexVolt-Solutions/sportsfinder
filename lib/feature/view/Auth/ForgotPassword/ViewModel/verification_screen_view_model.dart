// // // import 'package:flutter/material.dart';
// // // import 'package:sport_finding/Data/Repositories/verification_repositiry.dart';

// // // class VerificationScreenViewModel extends ChangeNotifier {
// // //   final VerificationRepository repository;
// // //   VerificationScreenViewModel({required this.repository});
// // //   final _formKey = GlobalKey<FormState>();
// // //   GlobalKey<FormState> get formKey => _formKey;

// // //   final TextEditingController _pinController = TextEditingController();
// // //   TextEditingController get pinController => _pinController;

// // //   bool _isLoading = false;
// // //   bool get isLoading => _isLoading;

// // //   Future<String?> verifyPin() async {
// // //     if (!_formKey.currentState!.validate()) {
// // //       return "Please fill all the fields";
// // //     }

// // //     try {
// // //       print(_pinController.text.trim());
// // //       _isLoading = true;
// // //       notifyListeners();
// // //       final response = await repository.resendOtp(
// // //         email: _pinController.text.trim(),
// // //       );
// // //       print('response: $response');
// // //       if (response['status'] == 'success') {
// // //         print(response['data']['token']);
// // //         return null;
// // //       }
// // //     } catch (e) {
// // //       print('error: $e');
// // //       return e.toString();
// // //     } finally {
// // //       _isLoading = false;
// // //       notifyListeners();
// // //     }
// // //     return null;
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _pinController.dispose();
// // //     super.dispose();
// // //   }
// // // }
// // import 'package:flutter/material.dart';
// // import 'package:sport_finding/Data/Repositories/forgot_password_repository.dart';

// // class VerificationScreenViewModel extends ChangeNotifier {
// //   final ForgotPasswordRepository repository;

// //   VerificationScreenViewModel({required this.repository});

// //   // final _formKey = GlobalKey<FormState>();
// //   // // GlobalKey<FormState> get formKey => _formKey;

// //   // // final TextEditingController _pinController = TextEditingController();
// //   // // TextEditingController get pinController => _pinController;

// //   // bool _isLoading = false;
// //   // bool get isLoading => _isLoading;

// //   // String _errorMessage = "";
// //   // String get errorMessage => _errorMessage;

// //   // Future<String?> resendOtp({required String email}) async {
// //   //   try {
// //   //     _isLoading = true;
// //   //     _errorMessage = '';
// //   //     notifyListeners();

// //   //     await repository.resendOtp(email: email);
// //   //     print("OTP Resent Successfully!");
// //   //     print(email);

// //   //     return null; // ✅ success
// //   //   } catch (e) {
// //   //     _errorMessage = e.toString();
// //   //     return _errorMessage;
// //   //   } finally {
// //   //     _isLoading = false;
// //   //     notifyListeners();
// //   //   }
// //   // }

// //   // @override
// //   // void dispose() {
// //   //   _pinController.dispose();
// //   //   super.dispose();
// //   // }
// // }
// import 'package:flutter/material.dart';
// import 'package:sport_finding/Data/Repositories/forgot_password_repository.dart';

// class VerificationScreenViewModel extends ChangeNotifier {
//   final ForgotPasswordRepository repository;

//   VerificationScreenViewModel({required this.repository});

//   final TextEditingController pinController = TextEditingController();

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

//   bool _isSuccess(dynamic response) {
//     if (response is Map<String, dynamic>) {
//       final message = response['message']?.toString().toLowerCase() ?? '';
//       return response['success'] == true ||
//           response['status'] == true ||
//           response['status'] == 200 ||
//           message.contains('success') ||
//           message.contains('verified');
//     }
//     return false;
//   }

//   // ================= VERIFY OTP =================
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

//       debugPrint("VERIFY OTP RESPONSE: $response");

//       return _isSuccess(response) ? null : _extractMessage(response);
//     } catch (e) {
//       debugPrint("VERIFY OTP ERROR: $e");
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
//       debugPrint("RESEND OTP RESPONSE: $response");

//       return _isSuccess(response) ? null : _extractMessage(response);
//     } catch (e) {
//       debugPrint("RESEND OTP ERROR: $e");
//       return e.toString().replaceAll('Exception:', '');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   @override
//   void dispose() {
//     pinController.dispose();
//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/forgot_password_repository.dart';

class VerificationScreenViewModel extends ChangeNotifier {
  final ForgotPasswordRepository repository;

  VerificationScreenViewModel({required this.repository});

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
          message.contains('verified') ||
          message.contains('success');
    }
    return false;
  }

  Future<String?> verifyOtp({
    required String email,
    required String otp,
  }) async {
    if (email.isEmpty) return 'Email is required';
    if (otp.length != 6) return 'Enter valid 6-digit OTP';

    try {
      _setLoading(true);

      final response = await repository.verifyOtp(email: email, otp: otp);

      debugPrint("VERIFY OTP RESPONSE: $response");

      return _isSuccess(response) ? null : _extractMessage(response);
    } catch (e) {
      return e.toString().replaceAll('Exception:', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> resendOtp({required String email}) async {
    try {
      _setLoading(true);

      final response = await repository.resendOtp(email: email);

      debugPrint("RESEND OTP RESPONSE: $response");

      return _isSuccess(response) ? null : _extractMessage(response);
    } catch (e) {
      return e.toString().replaceAll('Exception:', '');
    } finally {
      _setLoading(false);
    }
  }
}
