import 'dart:developer';
import 'package:sport_finding/Data/model/GetFollower/followers_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class FollowingRepo {
  final ApiService _apiService = ApiService();

  Future<FollowersModel> getFollowing({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      log('🚀 GET FOLLOWING API CALLED');
      log('🆔 User ID: $userId');
      log('📄 Page: $page | Limit: $limit');

      final response = await _apiService.get(
        '/api/v1/users/$userId/following?page=$page&limit=$limit',
      );

      log('📥 Following Response: $response');

      return FollowersModel.fromJson(response);
    } catch (e, stack) {
      log('❌ GET FOLLOWING ERROR: $e');
      log('$stack');
      rethrow;
    }
  }
}
