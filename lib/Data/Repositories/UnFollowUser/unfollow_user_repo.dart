import 'dart:developer';
import 'package:sport_finding/Data/model/UnFollowUser/unfollow_user_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class UnfollowUserRepo {
  final ApiService _apiService = ApiService();

  Future<UnfollowUserModel> unfollowUser({required String userId}) async {
    try {
      log("🚀 UNFOLLOW USER API CALLED");
      log("🆔 Target User ID: $userId");

      final response = await _apiService.delete("/api/v1/users/$userId/follow");

      log("📥 Response: $response");

      return UnfollowUserModel.fromJson(response);
    } catch (e, stack) {
      log("❌ UNFOLLOW USER ERROR: $e");
      log("$stack");
      rethrow;
    }
  }
}
// final repo = UnfollowUserRepo();

// final result = await repo.unfollowUser(
//   userId: "9d777b48-ee5d-44c9-a400-70b9093841a6",
// );

// print(result.message);
