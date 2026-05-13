import 'package:flutter/widgets.dart';
import 'package:sport_finding/core/Network/match_chat_service.dart';
import 'package:sport_finding/core/utils/logger.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_list_screen_view_model.dart';

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
      AppLogger.debug(
        'initial frame → broadcastClientPresence(online)',
        tag: 'AppLifecycle',
      );
      MatchChatService.broadcastClientPresence('online');
    });
  }

  AppLifecycleState? _last;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_last == state) return;
    final prev = _last;
    _last = state;
    AppLogger.info(
      'didChangeAppLifecycleState $prev → $state',
      tag: 'AppLifecycle',
    );
    switch (state) {
      case AppLifecycleState.resumed:
        AppLogger.debug(
          'resumed → broadcastClientPresence(online), schedule chat merge',
          tag: 'AppLifecycle',
        );
        MatchChatService.broadcastClientPresence('online');
        ChatListScreenViewModel.scheduleMergeDirectChatsFromBackend();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        AppLogger.debug(
          '$state → broadcastClientPresence(offline)',
          tag: 'AppLifecycle',
        );
        MatchChatService.broadcastClientPresence('offline');
        break;
      case AppLifecycleState.inactive:
         AppLogger.debug(
          'inactive (no presence change; may be transient)',
          tag: 'AppLifecycle',
        );
        break;
    }
  }
}
