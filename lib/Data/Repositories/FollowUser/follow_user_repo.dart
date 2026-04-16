import 'dart:developer';
import 'package:sport_finding/Data/model/FollowUser/follow_user_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class FollowUserRepo {
  final ApiService _apiService = ApiService();

  Future<FollowUserModel> followUser({required String userId}) async {
    try {
      log("🚀 FOLLOW USER API CALLED");
      log("🆔 Target User ID: $userId");

      final response = await _apiService.post("/api/v1/users/$userId/follow");

      log("📥 Response: $response");

      return FollowUserModel.fromJson(response);
    } catch (e, stack) {
      log("❌ FOLLOW USER ERROR: $e");
      log("$stack");
      rethrow;
    }
  }
}
//How to used
//final repo = FollowUserRepo();

// final result = await repo.followUser(
//   userId: "9d777b48-ee5d-44c9-a400-70b9093841a6",
// );

// print(result.message);
