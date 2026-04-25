class ChatRouteArgs {
  const ChatRouteArgs({
    required this.contactName,
    this.matchId,
    this.isOnline = true,
  });

  final String contactName;
  final String? matchId;
  final bool isOnline;
}
