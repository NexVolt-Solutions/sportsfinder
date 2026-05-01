class ChatRouteArgs {
  const ChatRouteArgs({
    required this.contactName,
    this.matchId,
    this.targetUserId,
    this.isOnline = true,
  });

  final String contactName;
  final String? matchId;
  final String? targetUserId;
  final bool isOnline;
}
