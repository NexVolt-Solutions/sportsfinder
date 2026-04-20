class InviteActionResponse {
  final String message;

  const InviteActionResponse({required this.message});

  factory InviteActionResponse.fromJson(Map<String, dynamic> json) {
    return InviteActionResponse(message: json['message']?.toString() ?? '');
  }
}
