import 'dart:developer';

import 'package:sport_finding/Data/model/Review/create_review_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class ReviewRepository {
  ReviewRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<CreateReviewResponseModel> createReview({
    required String userId,
    required CreateReviewRequestModel request,
  }) async {
    try {
      log(
        '[ReviewRepository] Create review API hit for userId=$userId, '
        'matchId=${request.matchId ?? 'n/a'}, rating=${request.rating}',
      );

      final response = await _apiService.post(
        '/api/v1/users/$userId/reviews',
        data: request.toJson(),
      );

      log(
        '[ReviewRepository] Create review API success for userId=$userId: '
        '$response',
      );

      return CreateReviewResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );
    } catch (e, stackTrace) {
      log(
        '[ReviewRepository] Create review API failed for userId=$userId: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
