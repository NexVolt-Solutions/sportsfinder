import 'package:sport_finding/Data/model/create_match_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class CreateMatchRepository {
  final ApiService apiService;

  CreateMatchRepository({required this.apiService});

  Future<CreateMatchModel> createMatch({
    required String title,
    required String description,
    required String sport,
    required String facilityAddress,
    required String scheduledAt,
    required int durationMinutes,
    required int maxPlayers,
    required String skillLevel,
    required String token,
  }) async {
    final response = await apiService.post(
      '/api/v1/matches',
      token: token,
      data: {
        'title': title,
        'description': description,
        'sport': sport,
        'facility_address': facilityAddress,
        'scheduled_at': scheduledAt,
        'duration_minutes': durationMinutes,
        'max_players': maxPlayers,
        'skill_level': skillLevel,
      },
    );

    return response;
  }
}
