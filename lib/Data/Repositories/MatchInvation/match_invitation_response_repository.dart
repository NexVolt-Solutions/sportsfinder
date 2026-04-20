// lib/Data/Repositories/match_invitation_response_repository.dart

import 'package:sport_finding/Data/model/MatchInvation/match_invitation_response_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/utils/logger.dart';

class MatchInvitationResponseRepository {
  final ApiService _api;

  MatchInvitationResponseRepository({ApiService? apiService})
    : _api = apiService ?? ApiService();

  /// Accept a match invitation
  /// Joins the match and notifies the host
  Future<AcceptInviteResponse> acceptInvite({required String matchId}) async {
    try {
      AppLogger.info(
        'Accepting match invitation...',
        tag: 'InviteResponseRepo',
      );
      AppLogger.debug('Match ID: $matchId', tag: 'InviteResponseRepo');

      // POST /api/v1/matches/{match_id}/invite/accept
      final response = await _api.post(
        '/api/v1/matches/$matchId/invite/accept',
      );

      AppLogger.success('Match invitation accepted', tag: 'InviteResponseRepo');
      AppLogger.debug('Response: $response', tag: 'InviteResponseRepo');

      return AcceptInviteResponse.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to accept invitation',
        tag: 'InviteResponseRepo',
        error: e,
        stackTrace: stackTrace,
      );

      // Handle specific error codes
      if (e.toString().contains('422')) {
        throw Exception('Invalid match ID or invitation not found');
      } else if (e.toString().contains('403')) {
        throw Exception('You are not authorized to accept this invitation');
      } else if (e.toString().contains('404')) {
        throw Exception('Match or invitation not found');
      } else if (e.toString().contains('409')) {
        throw Exception('Invitation already responded to or match is full');
      }

      rethrow;
    }
  }

  /// Decline a match invitation
  /// Notifies the host about the declined invitation
  Future<DeclineInviteResponse> declineInvite({required String matchId}) async {
    try {
      AppLogger.info(
        'Declining match invitation...',
        tag: 'InviteResponseRepo',
      );
      AppLogger.debug('Match ID: $matchId', tag: 'InviteResponseRepo');

      // POST /api/v1/matches/{match_id}/invite/decline
      final response = await _api.post(
        '/api/v1/matches/$matchId/invite/decline',
      );

      AppLogger.success('Match invitation declined', tag: 'InviteResponseRepo');
      AppLogger.debug('Response: $response', tag: 'InviteResponseRepo');

      return DeclineInviteResponse.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to decline invitation',
        tag: 'InviteResponseRepo',
        error: e,
        stackTrace: stackTrace,
      );

      // Handle specific error codes
      if (e.toString().contains('422')) {
        throw Exception('Invalid match ID or invitation not found');
      } else if (e.toString().contains('404')) {
        throw Exception('Match or invitation not found');
      }

      rethrow;
    }
  }

  /// Get pending invitations for current user
  Future<List<MatchInvitation>> getPendingInvitations() async {
    try {
      AppLogger.info(
        'Fetching pending invitations...',
        tag: 'InviteResponseRepo',
      );

      final response = await _api.get('/api/v1/matches/invitations/pending');

      AppLogger.success(
        'Pending invitations fetched',
        tag: 'InviteResponseRepo',
      );

      final List<dynamic> invitationsJson = response['data'] ?? [];

      return invitationsJson
          .map((json) => MatchInvitation.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch pending invitations',
        tag: 'InviteResponseRepo',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get invitation details by ID
  Future<MatchInvitation> getInvitationDetails({
    required String invitationId,
  }) async {
    try {
      AppLogger.info(
        'Fetching invitation details...',
        tag: 'InviteResponseRepo',
      );

      final response = await _api.get(
        '/api/v1/matches/invitations/$invitationId',
      );

      AppLogger.success(
        'Invitation details fetched',
        tag: 'InviteResponseRepo',
      );

      return MatchInvitation.fromJson(response['data']);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch invitation details',
        tag: 'InviteResponseRepo',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
