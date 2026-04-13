import 'package:sport_finding/core/Network/api_service.dart';

class MyProfileRepository {
  final ApiService apiService;
  MyProfileRepository({required this.apiService});

  // Existing
  Future<dynamic> getMyProfile({String? token}) async {
    final response = await apiService.get("/api/v1/users/me", token: token);

    return response;
  }

  // New - Get all users
  Future<dynamic> getAllUsers({String? token}) async {
    final response = await apiService.get("/api/v1/users", token: token);
    return response;
  }

  // New - Get user by ID
  Future<dynamic> getUserById(String userId, {String? token}) async {
    final response = await apiService.get(
      "/api/v1/users/$userId",
      token: token,
    );
    return response;
  }
}
