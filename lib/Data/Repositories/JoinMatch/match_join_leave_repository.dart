import 'dart:developer';
import 'package:sport_finding/Data/model/JoinMatch/join_leave_match_response.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class MatchJoinLeaveRepository {
  final ApiService _apiService = ApiService();

  /// JOIN a match by match_id
  Future<JoinLeaveMatchResponse> joinMatch(String matchId) async {
    try {
      log('🟡 [JoinMatch] Attempting to join match: $matchId');

      final response = await _apiService.post('/api/v1/matches/$matchId/join');

      log('✅ [JoinMatch] Success: $response');
      return JoinLeaveMatchResponse.fromJson(response);
    } catch (e) {
      log('❌ [JoinMatch] Error: $e');
      rethrow;
    }
  }

  /// LEAVE a match by match_id
  Future<JoinLeaveMatchResponse> leaveMatch(String matchId) async {
    try {
      log('🟡 [LeaveMatch] Attempting to leave match: $matchId');

      final response = await _apiService.delete(
        '/api/v1/matches/$matchId/leave',
      );

      log('✅ [LeaveMatch] Success: $response');

      // DELETE returns void in your ApiService, so we return a default message
      return JoinLeaveMatchResponse(message: 'Left match successfully');
    } catch (e) {
      log('❌ [LeaveMatch] Error: $e');
      rethrow;
    }
  }
}
