import 'dart:developer';
import 'package:sport_finding/Data/model/CreateReviewRequest/create_review_request_model.dart';
import 'package:sport_finding/core/Network/api_service.dart';

class CreateReviewRepo {
  final ApiService _apiService = ApiService();

  Future<CreateReviewModel> createReview({
    required String userId,
    required CreateReviewRequestModel data,
  }) async {
    try {
      log("🚀 CREATE REVIEW API CALLED");
      log("🆔 User ID: $userId");
      log("📦 Request: ${data.toJson()}");

      final response = await _apiService.post(
        "/api/v1/users/$userId/reviews",
        data: data.toJson(),
      );

      log("📥 Response: $response");

      return CreateReviewModel.fromJson(response);
    } catch (e, stack) {
      log("❌ CREATE REVIEW ERROR: $e");
      log("$stack");
      rethrow;
    }
  }
}

//how to used
// final repo = CreateReviewRepo();

// final result = await repo.createReview(
//   userId: "9d777b48-ee5d-44c9-a400-70b9093841a6",
//   data: CreateReviewRequestModel(
//     matchId: "match-id-here",
//     rating: 5,
//     comment: "Great player 👍",
//   ),
// );
