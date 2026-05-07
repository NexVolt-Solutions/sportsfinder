import 'package:sport_finding/Data/model/chat/direct_chats_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class DirectChatsRepository {
  DirectChatsRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<DirectChatsResponse> getDirectChats({
    int page = 1,
    int limit = 20,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit < 1 ? 20 : (limit > 100 ? 100 : limit);

    final endpoint = '/api/v1/chats?page=$safePage&limit=$safeLimit';
    final response = await _apiService.get(endpoint);
    return DirectChatsResponse.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<void> deleteDirectConversation({
    required String userId,
  }) async {
    final trimmed = userId.trim();
    if (trimmed.isEmpty) return;
    await _apiService.delete('/api/v1/chats/$trimmed');
  }
}

