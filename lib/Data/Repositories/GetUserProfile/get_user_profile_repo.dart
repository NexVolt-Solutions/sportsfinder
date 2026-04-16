import 'dart:developer';
import 'package:sport_finding/Data/model/GetUserProfile/get_user_profile_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class GetUserProfileRepo {
  final ApiService _apiService = ApiService();

  Future<GetUserProfileModel> getUserProfile({required String userId}) async {
    try {
      log("🚀 GET USER PROFILE API CALLED");
      log("🆔 User ID: $userId");

      final response = await _apiService.get("/api/v1/users/$userId");

      log("📥 Response: $response");

      final model = GetUserProfileModel.fromJson(response);

      log("✅ Parsed User: ${model.fullName}");

      return model;
    } catch (e, stack) {
      log("❌ GET USER PROFILE ERROR: $e");
      log("$stack");
      rethrow;
    }
  }
}

//how to used
// final repo = GetUserProfileRepo();

// final user = await repo.getUserProfile(
//   userId: "9d777b48-ee5d-44c9-a400-70b9093841a6",
// );
