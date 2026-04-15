import 'dart:io';
import 'package:flutter/foundation.dart';
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
    String? imagePath,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    try {
      print("========== SIGN UP API REQUEST ==========");
      print("Endpoint: /api/v1/auth/register");
      print("Full Name: $fullName");
      print("Email: $email");
      print("Accept Terms: $acceptTerms");

      print("Password: ${'*' * password.length} (masked)");
      print("Confirm Password: ${'*' * confirmPassword.length} (masked)");

      final File? imageFile = (!kIsWeb && imagePath != null)
          ? File(imagePath)
          : null;

      if (kIsWeb) {
        print("Platform: Web");
        print("Image Name: ${imageName ?? 'No image selected'}");
        print(
          "Image Bytes: ${imageBytes != null ? 'Provided' : 'Not Provided'}",
        );
      } else {
        print("Platform: Mobile");
        print("Image Path: ${imagePath ?? 'No image selected'}");
      }

      final fields = {
        "full_name": fullName,
        "email": email,
        "password": password,
        "confirm_password": confirmPassword,
        "accept_terms": acceptTerms ? "1" : "0",
      };

      print("Request Fields: $fields");

      final response = await apiService.postMultipart(
        "/api/v1/auth/register",
        fields: fields,
        file: imageFile,
        fileBytes: imageBytes,
        fileName: imageName,
        fileField: "profile_image",
      );

      print("========== SIGN UP API RESPONSE ==========");
      print(response);
      print("========== SIGN UP API COMPLETED ==========");

      return response;
    } catch (e, stackTrace) {
      print("========== SIGN UP API ERROR ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
  }
}
