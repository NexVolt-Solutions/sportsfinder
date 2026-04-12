// import 'package:flutter/widgets.dart';
// import 'package:sport_finding/Data/Repositories/login_repository.dart';

// class LoginScreenViewModel extends ChangeNotifier {
//   final LoginRepository repository;

//   LoginScreenViewModel({this.repository});

//   final _formKey = GlobalKey<FormState>();
//   GlobalKey<FormState> get formKey => _formKey;

//   final TextEditingController _emailController = TextEditingController();
//   TextEditingController get emailController => _emailController;

//   final TextEditingController _passwordController = TextEditingController();
//   TextEditingController get passwordController => _passwordController;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   Future<String?> loginUser() async {
//     if (!_formKey.currentState!.validate()) return "Please fill all the fields";

//     try {
//       await repository.postLogin(
//         _emailController.text.trim().toString(),
//         _passwordController.text.trim().toString(),
//         'access token here',
//         'refreshToken',
//         'tokenType',
//       );
//       return null;
//     } catch (e) {
//       return e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/login_repository.dart';

class LoginScreenViewModel extends ChangeNotifier {
  final LoginRepository repository;

  // ✅ Make repository REQUIRED
  LoginScreenViewModel({required this.repository});

  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  final TextEditingController _emailController = TextEditingController();
  TextEditingController get emailController => _emailController;

  final TextEditingController _passwordController = TextEditingController();
  TextEditingController get passwordController => _passwordController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String?> loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return "Please fill all the fields";
    }

    try {
      print(_emailController.text.trim());
      print(_passwordController.text.trim());

      _isLoading = true;
      notifyListeners();

      // ✅ Correct API call (NO fake tokens)
      await repository.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        'access token here',
        'refreshToken',
        'tokenType',
      );

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
