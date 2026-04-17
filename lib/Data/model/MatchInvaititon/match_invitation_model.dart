// lib/Data/model/match_invitation_model.dart

class MatchInvitationRequest {
  final String matchId;
  final String userId;

  MatchInvitationRequest({required this.matchId, required this.userId});

  Map<String, dynamic> toJson() {
    return {'match_id': matchId, 'user_id': userId};
  }
}

class MatchInvitationResponse {
  final String message;

  MatchInvitationResponse({required this.message});

  factory MatchInvitationResponse.fromJson(Map<String, dynamic> json) {
    return MatchInvitationResponse(
      message: json['message'] ?? 'Invitation sent successfully',
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message};
  }
}

class ValidationError {
  final List<ErrorDetail> detail;

  ValidationError({required this.detail});

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      detail:
          (json['detail'] as List<dynamic>?)
              ?.map((e) => ErrorDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get errorMessage {
    if (detail.isEmpty) return 'Validation error occurred';
    return detail.map((e) => e.msg).join(', ');
  }
}

class ErrorDetail {
  final List<dynamic> loc;
  final String msg;
  final String type;

  ErrorDetail({required this.loc, required this.msg, required this.type});

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      loc: json['loc'] ?? [],
      msg: json['msg'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'loc': loc, 'msg': msg, 'type': type};
  }
}
