// ignore_for_file: avoid_print

import 'package:sport_finding/core/Network/api_service.dart';

class MyProfileRepository {
  final ApiService apiService;

  MyProfileRepository({required this.apiService});

  // ================= GET MY PROFILE =================
  Future<dynamic> getMyProfile({String? token}) async {
    try {
      print("========== GET MY PROFILE REQUEST ==========");
      print("Endpoint: /api/v1/users/me");

      final response = await apiService.get("/api/v1/users/me", token: token);

      print("========== GET MY PROFILE RESPONSE ==========");
      print(response);
      print("========== GET MY PROFILE COMPLETED ==========");

      return response;
    } catch (e, stackTrace) {
      print("========== GET MY PROFILE ERROR ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
  }

  // ================= GET ALL USERS =================
  Future<dynamic> getAllUsers({String? token}) async {
    try {
      print("========== GET ALL USERS REQUEST ==========");
      print("Endpoint: /api/v1/users");

      final response = await apiService.get("/api/v1/users", token: token);

      print("========== GET ALL USERS RESPONSE ==========");
      print(
        "Response length: ${response is List ? response.length : 'Not a list'}",
      );
      print(response);
      print("========== GET ALL USERS COMPLETED ==========");

      return response;
    } catch (e, stackTrace) {
      print("========== GET ALL USERS ERROR ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
  }

  // ================= GET USER BY ID =================
  Future<dynamic> getUserById(String userId, {String? token}) async {
    try {
      print("========== GET USER BY ID REQUEST ==========");
      print("Endpoint: /api/v1/users/$userId");
      print("User ID: $userId");

      final response = await apiService.get(
        "/api/v1/users/$userId",
        token: token,
      );

      print("========== GET USER BY ID RESPONSE ==========");
      print(response);
      print("========== GET USER BY ID COMPLETED ==========");

      return response;
    } catch (e, stackTrace) {
      print("========== GET USER BY ID ERROR ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
  }
}
