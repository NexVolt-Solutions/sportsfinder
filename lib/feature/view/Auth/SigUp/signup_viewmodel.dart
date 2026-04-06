// import 'dart:io';

// import 'package:flutter/widgets.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:sport_finding/Data/Repositories/registration_repository.dart';

// class SignUpViewModel extends ChangeNotifier {
//   final RegistrationRepository repository;

//   SignUpViewModel({ImagePicker? imagePicker, required this.repository})
//     : _imagePicker = imagePicker ?? ImagePicker();

//   final ImagePicker _imagePicker;

//   final _formKey = GlobalKey<FormState>();
//   GlobalKey<FormState> get formKey => _formKey;

//   final TextEditingController _fullNameController = TextEditingController();
//   TextEditingController get fullNameController => _fullNameController;

//   final TextEditingController _emailController = TextEditingController();
//   TextEditingController get emailController => _emailController;

//   final TextEditingController _phoneNumberController = TextEditingController();
//   TextEditingController get phoneNumberController => _phoneNumberController;

//   final TextEditingController _passwordController = TextEditingController();
//   TextEditingController get passwordController => _passwordController;

//   final TextEditingController _confirmPasswordController =
//       TextEditingController();
//   TextEditingController get confirmPasswordController =>
//       _confirmPasswordController;

//   String? _profileImagePath;
//   String? get profileImagePath => _profileImagePath;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   Future<String?> registerUser() async {
//     if (!_formKey.currentState!.validate()) return "Please fill all the fields";
//     try {
//       _isLoading = true;
//       notifyListeners();

//       await repository.registerWithImage(
//         fullName: _fullNameController.text.trim().toString(),
//         email: _emailController.text.trim().toString(),
//         phoneNumber: _phoneNumberController.text.trim().toString(),
//         password: _passwordController.text.trim().toString(),
//         confirmPassword: _confirmPasswordController.text.trim().toString(),
//         acceptTerms: true,
//         image: _profileImagePath != null ? File(_profileImagePath!) : null,
//       );
//       return null;
//     } catch (e) {
//       return e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// Picks an image from the gallery. Returns `null` on success or if the user
//   /// cancels; returns a short error message on failure (show in UI).
//   Future<String?> pickProfileImageFromGallery() async {
//     try {
//       final file = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );
//       if (file == null) return null;
//       _profileImagePath = file.path;
//       notifyListeners();
//       return null;
//     } catch (_) {
//       return 'Could not open gallery';
//     }
//   }

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _phoneNumberController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_finding/Data/Repositories/registration_repository.dart';

class SignUpViewModel extends ChangeNotifier {
  final RegistrationRepository repository;

  SignUpViewModel({ImagePicker? imagePicker, required this.repository})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  final TextEditingController _fullNameController = TextEditingController();
  TextEditingController get fullNameController => _fullNameController;

  final TextEditingController _emailController = TextEditingController();
  TextEditingController get emailController => _emailController;

  final TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController get phoneNumberController => _phoneNumberController;

  final TextEditingController _passwordController = TextEditingController();
  TextEditingController get passwordController => _passwordController;

  final TextEditingController _confirmPasswordController =
      TextEditingController();
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;

  String? _profileImagePath;
  String? get profileImagePath => _profileImagePath;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String?> registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return "Please fill all fields";
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      return "Passwords do not match";
    }

    try {
      _isLoading = true;
      notifyListeners();

      await repository.registerWithImage(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
        acceptTerms: true,
        image: _profileImagePath != null ? File(_profileImagePath!) : null,
      );

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> pickProfileImageFromGallery() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file == null) return null;

      _profileImagePath = file.path;
      notifyListeners();

      return null;
    } catch (e) {
      return "Failed to pick image";
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
