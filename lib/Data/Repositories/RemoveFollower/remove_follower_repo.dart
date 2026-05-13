import 'dart:developer';

import 'package:sport_finding/Data/model/UnFollowUser/unfollow_user_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

 
class RemoveFollowerRepo {
  RemoveFollowerRepo({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<UnfollowUserModel> removeFollower({
    required String followerUserId,
  }) async {
    final id = followerUserId.trim();
    if (id.isEmpty) {
      throw ArgumentError('followerUserId must not be empty');
    }
    try {
      log('🚀 REMOVE FOLLOWER API userId=$id');
      final response = await _apiService.delete(
        '/api/v1/users/me/followers/$id',
      );
      if (response == null) {
        return UnfollowUserModel(message: '');
      }
      if (response is Map) {
        return UnfollowUserModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
      return UnfollowUserModel(message: '');
    } catch (e, stack) {
      log('❌ REMOVE FOLLOWER ERROR: $e');
      log('$stack');
      rethrow;
    }
  }
}
