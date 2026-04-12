import 'package:flutter/material.dart';

class NewPasswordScreenViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // bool _isLoading = false;
  // bool get isLoading => _isLoading;

  // Future<String?> newPassword() async {
  //   if (!formKey.currentState!.validate()) {
  //     return "Please fill all the fields";
  //   }

  //   try {
  //     _isLoading = true;
  //     notifyListeners();
  //     final response = await repository.newPassword(
  //       passwordController.text.trim(),
  //       confirmPasswordController.text.trim(),
  //     );
  //     print('response: $response');
  //     if (response['status'] == 'success') {
  //       print(response['data']['token']);
  //       return null;
  //     }
  //   } catch (e) {
  //     print('error: $e');
  //     return e.toString();
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  //   return null;
  // }
}
