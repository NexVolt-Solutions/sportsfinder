class ChatRouteArgs {
  const ChatRouteArgs({
    required this.contactName,
    this.targetUserId,
    this.isOnline = true,
  });

  final String contactName;
  final String? targetUserId;
  final bool isOnline;
}
