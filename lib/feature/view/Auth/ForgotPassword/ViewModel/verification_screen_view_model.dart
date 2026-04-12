// import 'package:flutter/material.dart';
// import 'package:sport_finding/Data/Repositories/verification_repositiry.dart';

// class VerificationScreenViewModel extends ChangeNotifier {
//   final VerificationRepository repository;
//   VerificationScreenViewModel({required this.repository});
//   final _formKey = GlobalKey<FormState>();
//   GlobalKey<FormState> get formKey => _formKey;

//   final TextEditingController _pinController = TextEditingController();
//   TextEditingController get pinController => _pinController;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   Future<String?> verifyPin() async {
//     if (!_formKey.currentState!.validate()) {
//       return "Please fill all the fields";
//     }

//     try {
//       print(_pinController.text.trim());
//       _isLoading = true;
//       notifyListeners();
//       final response = await repository.resendOtp(
//         email: _pinController.text.trim(),
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

//   @override
//   void dispose() {
//     _pinController.dispose();
//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/forgot_password_repository.dart';

class VerificationScreenViewModel extends ChangeNotifier {
  final ForgotPasswordRepository repository;

  VerificationScreenViewModel({required this.repository});

  // final _formKey = GlobalKey<FormState>();
  // // GlobalKey<FormState> get formKey => _formKey;

  // // final TextEditingController _pinController = TextEditingController();
  // // TextEditingController get pinController => _pinController;

  // bool _isLoading = false;
  // bool get isLoading => _isLoading;

  // String _errorMessage = "";
  // String get errorMessage => _errorMessage;

  // Future<String?> resendOtp({required String email}) async {
  //   try {
  //     _isLoading = true;
  //     _errorMessage = '';
  //     notifyListeners();

  //     await repository.resendOtp(email: email);
  //     print("OTP Resent Successfully!");
  //     print(email);

  //     return null; // ✅ success
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //     return _errorMessage;
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // @override
  // void dispose() {
  //   _pinController.dispose();
  //   super.dispose();
  // }
}
