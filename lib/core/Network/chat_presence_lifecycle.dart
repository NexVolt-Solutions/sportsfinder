import 'package:flutter/widgets.dart';
import 'package:sport_finding/core/Network/match_chat_service.dart';

/// Pushes best-effort `presence_update` frames on open chat WebSockets when the
/// app moves between foreground and background so peers can show offline + last
/// seen (if the server echoes/broadcasts these events).
class ChatPresenceLifecycle with WidgetsBindingObserver {
  ChatPresenceLifecycle._();
  static final ChatPresenceLifecycle instance = ChatPresenceLifecycle._();

  static void register() {
    final binding = WidgetsBinding.instance;
    binding.addObserver(instance);
    binding.addPostFrameCallback((_) {
      MatchChatService.broadcastClientPresence('online');
    });
  }

  AppLifecycleState? _last;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_last == state) return;
    _last = state;
    switch (state) {
      case AppLifecycleState.resumed:
        MatchChatService.broadcastClientPresence('online');
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        MatchChatService.broadcastClientPresence('offline');
        break;
      case AppLifecycleState.inactive:
        // Avoid toggling offline on transient inactive (e.g. system sheet / IME).
        break;
    }
  }
}
