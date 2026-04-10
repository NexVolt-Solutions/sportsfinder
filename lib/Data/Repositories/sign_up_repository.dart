// import 'dart:io';
// import 'package:sport_finding/core/Network/api_service.dart';

// class SignUpRepository {
//   final ApiService apiService;

//   SignUpRepository({required this.apiService});

//   Future<void> signUpUser({
//     required String fullName,
//     required String email,
//     required String phone,
//     required String password,
//     required String confirmPassword,
//     required bool acceptTerms,
//     File? image,
//   }) async {
//     final response = await apiService.postMultipart(
//       "/api/v1/auth/register",
//       fields: {
//         "full_name": fullName,
//         "email": email,
//         "phone": phone,
//         "password": password,
//         "confirm_password": confirmPassword,
//         "accept_terms": acceptTerms.toString(),
//       },
//       file: image,
//       fileField: "profile_image",
//     );

//     return response;
//   }
// }

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sport_finding/core/Network/api_service.dart';

class SignUpRepository {
  final ApiService apiService;

  SignUpRepository({required this.apiService});

  Future<void> signUpUser({
    required String fullName,
    required String email,
    // required String phone,
    required String password,
    required String confirmPassword,
    required bool acceptTerms,
    String? imagePath, // 📱 Mobile
    List<int>? imageBytes, // 🌐 Web
    String? imageName, // 🌐 Web
  }) async {
    final response = await apiService.postMultipart(
      "/api/v1/auth/register",
      fields: {
        "full_name": fullName,
        "email": email,
        // "phone": phone,
        "password": password,
        "confirm_password": confirmPassword,
        "accept_terms": acceptTerms.toString(),
      },
      filePath: kIsWeb ? null : imagePath,
      fileBytes: kIsWeb ? imageBytes : null,
      fileName: kIsWeb ? imageName : null,
      fileField: "profile_image",
    );
    print(response.toString());
    return response;
  }
}
