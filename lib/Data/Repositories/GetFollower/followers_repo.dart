import 'dart:developer';
import 'package:sport_finding/Data/model/GetFollower/followers_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class FollowersRepo {
  final ApiService _apiService = ApiService();

  Future<FollowersModel> getFollowers({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      log("🚀 GET FOLLOWERS API CALLED");
      log("🆔 User ID: $userId");
      log("📄 Page: $page | Limit: $limit");

      final response = await _apiService.get(
        "/api/v1/users/$userId/followers?page=$page&limit=$limit",
      );

      log("📥 Response: $response");

      return FollowersModel.fromJson(response);
    } catch (e, stack) {
      log("❌ GET FOLLOWERS ERROR: $e");
      log("$stack");
      rethrow;
    }
  }
}
// final repo = FollowersRepo();

// final result = await repo.getFollowers(
//   userId: "9d777b48-ee5d-44c9-a400-70b9093841a6",
//   page: 1,
//   limit: 20,
// );

// print(result.items.length);
