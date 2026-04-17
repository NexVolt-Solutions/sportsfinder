// lib/Data/Repositories/match_invitation_repository.dart

import 'package:sport_finding/Data/model/MatchInvaititon/match_invitation_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/utils/logger.dart';

class MatchInvitationRepository {
  final ApiService _api;

  MatchInvitationRepository({ApiService? apiService})
    : _api = apiService ?? ApiService();

  /// Invite a user to join a match
  /// Host only - Sends MATCH_INVITED notification with Accept/Decline actions
  Future<MatchInvitationResponse> invitePlayer({
    required String matchId,
    required String userId,
  }) async {
    try {
      AppLogger.info('Inviting player to match...', tag: 'MatchInvitationRepo');
      AppLogger.debug('Match ID: $matchId', tag: 'MatchInvitationRepo');
      AppLogger.debug('User ID: $userId', tag: 'MatchInvitationRepo');

      // API Call
      final response = await _api.post(
        '/api/v1/matches/$matchId/invite/$userId',
      );

      AppLogger.success(
        'Player invited successfully',
        tag: 'MatchInvitationRepo',
      );
      AppLogger.debug('Response: $response', tag: 'MatchInvitationRepo');

      return MatchInvitationResponse.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to invite player',
        tag: 'MatchInvitationRepo',
        error: e,
        stackTrace: stackTrace,
      );

      // Handle validation errors specifically
      if (e.toString().contains('422')) {
        throw Exception('Invalid match ID or user ID provided');
      }

      rethrow;
    }
  }

  /// Invite multiple players to a match
  Future<List<MatchInvitationResponse>> inviteMultiplePlayers({
    required String matchId,
    required List<String> userIds,
  }) async {
    try {
      AppLogger.info(
        'Inviting ${userIds.length} players to match...',
        tag: 'MatchInvitationRepo',
      );

      final List<MatchInvitationResponse> results = [];

      for (final userId in userIds) {
        try {
          final response = await invitePlayer(matchId: matchId, userId: userId);
          results.add(response);
        } catch (e) {
          AppLogger.warning(
            'Failed to invite user $userId: $e',
            tag: 'MatchInvitationRepo',
          );
          // Continue with other invitations even if one fails
        }
      }

      AppLogger.success(
        'Invited ${results.length}/${userIds.length} players',
        tag: 'MatchInvitationRepo',
      );

      return results;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to invite multiple players',
        tag: 'MatchInvitationRepo',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
