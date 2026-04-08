import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_finding/Data/Repositories/sign_up_repository.dart';

class SignUpViewModel extends ChangeNotifier {
  final SignUpRepository repository;

  SignUpViewModel({required this.repository, ImagePicker? imagePicker})
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

  /// 🔥 PICK IMAGE
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

  /// 🔥 REGISTER USER (MULTIPART)
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

      await repository.signUpUser(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneNumberController.text.trim(),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
        acceptTerms: true,
        image: _profileImagePath != null ? File(_profileImagePath!) : null,
      );

      return null; // success
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
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
