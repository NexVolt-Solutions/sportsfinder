// lib/Data/model/match_invitation_response_model.dart

/// Request model for accepting match invitation
class AcceptInviteRequest {
  final String matchId;

  AcceptInviteRequest({required this.matchId});

  Map<String, dynamic> toJson() {
    return {'match_id': matchId};
  }
}

/// Response model for accepting match invitation
class AcceptInviteResponse {
  final String message;

  AcceptInviteResponse({required this.message});

  factory AcceptInviteResponse.fromJson(Map<String, dynamic> json) {
    return AcceptInviteResponse(
      message: json['message'] ?? 'Successfully joined the match',
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message};
  }
}

/// Request model for declining match invitation
class DeclineInviteRequest {
  final String matchId;

  DeclineInviteRequest({required this.matchId});

  Map<String, dynamic> toJson() {
    return {'match_id': matchId};
  }
}

/// Response model for declining match invitation
class DeclineInviteResponse {
  final String message;

  DeclineInviteResponse({required this.message});

  factory DeclineInviteResponse.fromJson(Map<String, dynamic> json) {
    return DeclineInviteResponse(
      message: json['message'] ?? 'Invitation declined',
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message};
  }
}

/// Validation error model
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

  Map<String, dynamic> toJson() {
    return {'detail': detail.map((e) => e.toJson()).toList()};
  }

  String get errorMessage {
    if (detail.isEmpty) return 'Validation error occurred';
    return detail.map((e) => e.msg).join(', ');
  }
}

/// Error detail model
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

/// Match invitation status enum
enum InvitationStatus { pending, accepted, declined, expired }

/// Match invitation model
class MatchInvitation {
  final String id;
  final String matchId;
  final String userId;
  final String hostId;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  MatchInvitation({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.hostId,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory MatchInvitation.fromJson(Map<String, dynamic> json) {
    return MatchInvitation(
      id: json['id'] ?? '',
      matchId: json['match_id'] ?? '',
      userId: json['user_id'] ?? '',
      hostId: json['host_id'] ?? '',
      status: _parseStatus(json['status']),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_id': matchId,
      'user_id': userId,
      'host_id': hostId,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
    };
  }

  static InvitationStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return InvitationStatus.accepted;
      case 'declined':
        return InvitationStatus.declined;
      case 'expired':
        return InvitationStatus.expired;
      default:
        return InvitationStatus.pending;
    }
  }

  bool get isPending => status == InvitationStatus.pending;
  bool get isAccepted => status == InvitationStatus.accepted;
  bool get isDeclined => status == InvitationStatus.declined;
  bool get isExpired => status == InvitationStatus.expired;
}
