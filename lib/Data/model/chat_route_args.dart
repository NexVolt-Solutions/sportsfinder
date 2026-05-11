class ChatRouteArgs {
  const ChatRouteArgs({
    required this.contactName,
    this.targetUserId,
    this.isOnline = true,
    this.contactAvatarUrl,
  });

  final String contactName;
  final String? targetUserId;
  final bool isOnline;
  /// Peer avatar (HTTP(S) URL). Shown in chat header when set; list threads may also merge this in.
  final String? contactAvatarUrl;
}
