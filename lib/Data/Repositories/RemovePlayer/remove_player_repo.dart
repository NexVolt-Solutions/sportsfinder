import 'dart:developer';

import 'package:sport_finding/Data/model/RemovePlayer/remove_player_response_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class RemovePlayerRepo {
  final ApiService _apiService = ApiService();

  Future<RemovePlayerResponseModel> removePlayer({
    required String matchId,
    required String userId,
  }) async {
    final trimmedMatchId = matchId.trim();
    final trimmedUserId = userId.trim();
    if (trimmedMatchId.isEmpty) {
      throw ArgumentError('matchId is required');
    }
    if (trimmedUserId.isEmpty) {
      throw ArgumentError('userId is required');
    }

    final endpoint = '/api/v1/matches/$trimmedMatchId/players/$trimmedUserId';

    try {
      log('DELETE $endpoint', name: 'RemovePlayerRepo');
      final response = await _apiService.delete(endpoint);
      if (response is! Map<String, dynamic>) {
        throw Exception('Unexpected remove player response');
      }
      return RemovePlayerResponseModel.fromJson(response);
    } catch (e, stackTrace) {
      log(
        'Failed to remove player from match. matchId=$trimmedMatchId userId=$trimmedUserId error=$e',
        name: 'RemovePlayerRepo',
        level: 1000,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
