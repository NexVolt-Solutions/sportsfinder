// // import 'dart:io';
// // import 'package:sport_finding/core/Network/api_service.dart';

// // class SignUpRepository {
// //   final ApiService apiService;

// //   SignUpRepository({required this.apiService});

// //   Future<void> signUpUser({
// //     required String fullName,
// //     required String email,
// //     required String phone,
// //     required String password,
// //     required String confirmPassword,
// //     required bool acceptTerms,
// //     File? image,
// //   }) async {
// //     final response = await apiService.postMultipart(
// //       "/api/v1/auth/register",
// //       fields: {
// //         "full_name": fullName,
// //         "email": email,
// //         "phone": phone,
// //         "password": password,
// //         "confirm_password": confirmPassword,
// //         "accept_terms": acceptTerms.toString(),
// //       },
// //       file: image,
// //       fileField: "profile_image",
// //     );

// //     return response;
// //   }
// // }
// import 'dart:io';
// import 'package:sport_finding/core/Network/api_service.dart';

// class SignUpRepository {
//   final ApiService apiService;

//   SignUpRepository({required this.apiService});

//   Future<Map<String, dynamic>> signUpUser({
//     required String fullName,
//     required String email,
//     // required String phone,
//     required String password,
//     required String confirmPassword,
//     required bool acceptTerms,
//     String? imagePath, // 📱 Mobile
//     List<int>? imageBytes, // 🌐 Web
//     String? imageName, // 🌐 Web
//   }) async {
//     try {
//       print("🔵 SignUpRepository - Starting registration");
//       print("📧 Email: $email");
//       print("👤 Name: $fullName");
//       print("🖼️ Image: ${image?.path ?? 'No image'}");

//       final response = await apiService.postMultipart(
//         "/api/v1/auth/register",
//         fields: {
//           "full_name": fullName,
//           "email": email,

//           "password": password,
//           "confirm_password":
//               confirmPassword, // ⚠️ Changed from confirm_password
//           "accept_terms": acceptTerms
//               ? "1"
//               : "0", // ⚠️ Use 1/0 instead of true/false
//         },
//         file: image,
//         fileField: "profile_image",
//       );

//       print("✅ Registration successful");
//       return response;
//     } catch (e) {
//       print("❌ Registration error: $e");
//       rethrow;
//     }
//   }
// }
import 'dart:io';
import 'package:flutter/foundation.dart'; // ✅ for kIsWeb
import 'package:sport_finding/core/Network/api_service.dart';

class SignUpRepository {
  final ApiService apiService;

  SignUpRepository({required this.apiService});

  Future<Map<String, dynamic>> signUpUser({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required bool acceptTerms,
    String? imagePath, // 📱 Mobile
    List<int>? imageBytes, // 🌐 Web
    String? imageName, // 🌐 Web
  }) async {
    try {
      print("🔵 SignUpRepository - Starting registration");
      print("📧 Email: $email");
      print("👤 Name: $fullName");
      print("🖼️ ImagePath: ${imagePath ?? 'No image'}");

      // ✅ Convert imagePath to File for mobile
      final File? imageFile = (!kIsWeb && imagePath != null)
          ? File(imagePath)
          : null;

      final response = await apiService.postMultipart(
        "/api/v1/auth/register",
        fields: {
          "full_name": fullName,
          "email": email,
          "password": password,
          "confirm_password": confirmPassword,
          "accept_terms": acceptTerms ? "1" : "0",
        },
        file: imageFile, // 📱 Mobile: File object
        fileBytes: imageBytes, // 🌐 Web: bytes
        fileName: imageName, // 🌐 Web: filename
        fileField: "profile_image",
      );

      print("✅ Registration successful");
      return response;
    } catch (e) {
      print("❌ Registration error: $e");
      rethrow;
    }
  }
}
