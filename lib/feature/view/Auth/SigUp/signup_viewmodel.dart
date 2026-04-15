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
import 'package:image_picker/image_picker.dart';
import 'package:sport_finding/Data/Repositories/sign_up_repository.dart';

class SignUpViewModel extends ChangeNotifier {
  final SignUpRepository repository;
  final ImagePicker _imagePicker;

  SignUpViewModel({required this.repository, ImagePicker? imagePicker})
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
