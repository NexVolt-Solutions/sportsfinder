class JoinLeaveMatchResponse {
  final String message;

  JoinLeaveMatchResponse({required this.message});

  factory JoinLeaveMatchResponse.fromJson(Map<String, dynamic> json) {
    return JoinLeaveMatchResponse(message: json['message'] ?? '');
  }
}
