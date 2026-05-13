import 'package:sport_finding/Data/model/chat_route_args.dart';

/// Carries a direct-chat open request from routes that sit above [BottomBarScreen]
/// (e.g. public profile on web) into the embedded [ChatListScreen] / [WebChatContent].
class WebEmbeddedChatOpenCoordinator {
  WebEmbeddedChatOpenCoordinator._();

  static ChatRouteArgs? _pending;

  static bool get hasPending => _pending != null;

  static void requestOpen(ChatRouteArgs args) {
    _pending = args;
  }

  /// Removes and returns any pending open. Call from the embedded chat tab only.
  static ChatRouteArgs? takePending() {
    final p = _pending;
    _pending = null;
    return p;
  }
}
