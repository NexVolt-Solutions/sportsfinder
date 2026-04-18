import 'dart:developer';
import 'package:sport_finding/Data/model/UpdateMatchStatus/update_match_status_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class UpdateMatchStatusRepo {
  final ApiService _apiService = ApiService();

  Future<UpdateMatchStatusModel> updateMatchStatus({
    required String matchId,
    required UpdateMatchStatusRequestModel data,
  }) async {
    try {
      log(
        '========== UPDATE MATCH STATUS REQUEST ==========',
        name: 'UpdateMatchStatusRepo',
      );
      log('Match ID: $matchId', name: 'UpdateMatchStatusRepo');
      log(
        'Endpoint: /api/v1/matches/$matchId/status',
        name: 'UpdateMatchStatusRepo',
      );
      log('Request Data: ${data.toJson()}', name: 'UpdateMatchStatusRepo');

      final response = await _apiService.patch(
        '/api/v1/matches/$matchId/status',
        data: data.toJson(),
      );

      log(
        '========== UPDATE MATCH STATUS RESPONSE ==========',
        name: 'UpdateMatchStatusRepo',
      );
      log('$response', name: 'UpdateMatchStatusRepo');

      if (response == null) {
        throw Exception('API returned null when updating match status');
      }
      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Expected Map<String, dynamic> but got ${response.runtimeType}',
        );
      }

      return UpdateMatchStatusModel.fromJson(response);
    } catch (e, stackTrace) {
      log(
        '========== UPDATE MATCH STATUS ERROR ==========\nError: $e',
        name: 'UpdateMatchStatusRepo',
        level: 1000,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
