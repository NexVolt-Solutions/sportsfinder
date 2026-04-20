import 'package:sport_finding/Data/model/MatchInvitation/invite_action_response_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/utils/logger.dart';

class InviteActionRepository {
  InviteActionRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<InviteActionResponse> acceptInvite({required String matchId}) async {
    try {
      AppLogger.info(
        'Accept invite request started for matchId: $matchId',
        tag: 'InviteActionRepo',
      );
      AppLogger.debug(
        'Backend accepts invitations through POST /api/v1/matches/$matchId/join',
        tag: 'InviteActionRepo',
      );
      final response = await _apiService.post(
        '/api/v1/matches/$matchId/join',
      );
      AppLogger.success(
        'Accept invite request completed for matchId: $matchId',
        tag: 'InviteActionRepo',
      );
      return InviteActionResponse.fromJson(Map<String, dynamic>.from(response));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Accept invite request failed for matchId: $matchId',
        tag: 'InviteActionRepo',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<InviteActionResponse> declineInvite({required String matchId}) async {
    try {
      AppLogger.info(
        'Decline invite request started for matchId: $matchId',
        tag: 'InviteActionRepo',
      );
      final response = await _apiService.post(
        '/api/v1/matches/$matchId/invite/decline',
      );
      AppLogger.success(
        'Decline invite request completed for matchId: $matchId',
        tag: 'InviteActionRepo',
      );
      return InviteActionResponse.fromJson(Map<String, dynamic>.from(response));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Decline invite request failed for matchId: $matchId',
        tag: 'InviteActionRepo',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
