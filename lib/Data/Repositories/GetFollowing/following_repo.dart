import 'dart:developer';
import 'package:sport_finding/Data/model/GetFollower/followers_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class FollowingRepo {
  final ApiService _apiService = ApiService();
  static const int _maxLimit = 100;
  static const int _defaultLimit = 20;

  int _sanitizeLimit(int limit) {
    if (limit <= 0) return _defaultLimit;
    if (limit > _maxLimit) return _maxLimit;
    return limit;
  }

  Future<FollowersModel> getFollowing({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final safeLimit = _sanitizeLimit(limit);
      log('🚀 GET FOLLOWING API CALLED');
      log('🆔 User ID: $userId');
      log('📄 Page: $page | Limit: $safeLimit');

      final response = await _apiService.get(
        '/api/v1/users/$userId/following?page=$page&limit=$safeLimit',
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
