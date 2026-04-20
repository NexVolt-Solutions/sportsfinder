import 'dart:developer';

import 'package:sport_finding/Data/model/DeleteMAtch/delete_match_Model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class DeleteMatchRepo {
  final ApiService _apiService = ApiService();

  Future<DeleteMatchModel> deleteMatch({required String matchId}) async {
    final trimmedMatchId = matchId.trim();
    if (trimmedMatchId.isEmpty) {
      throw ArgumentError('matchId is required');
    }

    try {
      log(
        '========== DELETE MATCH REQUEST ==========',
        name: 'DeleteMatchRepo',
      );
      log('Match ID: $trimmedMatchId', name: 'DeleteMatchRepo');
      log(
        'Endpoint: /api/v1/matches/$trimmedMatchId',
        name: 'DeleteMatchRepo',
      );

      await _apiService.delete('/api/v1/matches/$trimmedMatchId');

      log(
        '========== DELETE MATCH SUCCESS ==========',
        name: 'DeleteMatchRepo',
      );
      return DeleteMatchModel(matchId: trimmedMatchId);
    } catch (e, stackTrace) {
      final errorText = e.toString();
      if (errorText.contains('Match not found')) {
        log(
          '========== DELETE MATCH ALREADY REMOVED ==========\n'
          'Server reported match not found, treating as deleted for UI sync.',
          name: 'DeleteMatchRepo',
        );
        return DeleteMatchModel(matchId: trimmedMatchId);
      }
      log(
        '========== DELETE MATCH ERROR ==========\nError: $e',
        name: 'DeleteMatchRepo',
        level: 1000,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
