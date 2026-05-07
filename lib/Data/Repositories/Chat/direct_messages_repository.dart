import 'package:sport_finding/core/Network/api_service.dart';

enum DeleteMessageScope {
  me,
  both,
}

class DirectMessagesRepository {
  DirectMessagesRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<void> deleteDirectMessage({
    required String userId,
    required String messageId,
    required DeleteMessageScope scope,
  }) async {
    final trimmedUserId = userId.trim();
    final trimmedMessageId = messageId.trim();
    if (trimmedUserId.isEmpty || trimmedMessageId.isEmpty) return;

    await _apiService.delete(
      '/api/v1/users/$trimmedUserId/messages/$trimmedMessageId',
      data: <String, dynamic>{
        'scope': scope == DeleteMessageScope.both ? 'both' : 'me',
      },
    );
  }
}

