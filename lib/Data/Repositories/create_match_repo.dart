// import 'package:sport_finding/Data/model/create_match_request_model.dart';
// import 'package:sport_finding/core/Network/api_service.dart';

// class MatchRepository {
//   final ApiService _api = ApiService();

//   Future<MatchModel> createMatch(Map<String, dynamic> data) async {
//     final response = await _api.post('/api/v1/matches', data: data);
//     return MatchModel.fromJson(response);
//   }
// }
import 'dart:developer';
import 'package:sport_finding/Data/model/create_match_request_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class MatchRepository {
  final ApiService _api = ApiService();

  Future<MatchModel> createMatch(Map<String, dynamic> data) async {
    try {
      // 📤 Log Request Details
      log('Creating Match...', name: 'MatchRepository');

      log('API Endpoint: /api/v1/matches', name: 'MatchRepository');

      log('Request Payload: $data', name: 'MatchRepository');

      // 🌐 API Call
      final response = await _api.post('/api/v1/matches', data: data);

      // 📥 Log Response
      log('API Response: $response', name: 'MatchRepository');

      final match = MatchModel.fromJson(response);

      // ✅ Log Parsed Data
      log(
        'Match Created Successfully! Match ID: ${match.id}',
        name: 'MatchRepository',
      );

      return match;
    } catch (e, stackTrace) {
      // ❌ Log Errors
      log(
        'Error Creating Match: $e',
        name: 'MatchRepository',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // Severe error level
      );
      rethrow;
    }
  }
}
