import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:sport_finding/Data/model/chat_route_args.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/utils/date_time_formatters.dart';
import 'package:sport_finding/core/Network/chat_realtime_events.dart';
import 'package:sport_finding/core/Network/fcm_local_notifications.dart';
import 'package:sport_finding/core/Network/match_chat_service.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/web_embedded_chat_open_coordinator.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_list_screen_view_model.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_screen_view_model.dart'
    show ChatScreenMessagesCache;
import 'package:sport_finding/feature/view/BottomBar/Components/Chat/web/web_chat_content.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';
import 'package:sport_finding/feature/widget/app_dialog.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key, this.embedInBottomBar = false});

  /// When true, [BottomBarScreen] supplies the shared [AppBarWidget].
  final bool embedInBottomBar;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with WidgetsBindingObserver {
  static const int _chatTabIndex = 3;
  static const double _webCompactBreakpoint = 980;
  static const Duration _webHistoryGapFillInterval = Duration(seconds: 12);

  ChatListScreenViewModel? _vm;
  ChatListScreenViewModel get _safeVm => _vm ??= ChatListScreenViewModel();
  final TextEditingController _webMessageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedWebTargetUserId;
  bool _webUnreadOnly = false;
  final Map<String, List<WebChatMessageItem>> _webThreadMessages =
      <String, List<WebChatMessageItem>>{};
  final Map<String, MatchChatService> _webThreadServices =
      <String, MatchChatService>{};
  final Map<String, StreamSubscription<RealtimeChatMessage>> _webMessageSubs =
      <String, StreamSubscription<RealtimeChatMessage>>{};
  final Map<String, StreamSubscription<String>> _webErrorSubs =
      <String, StreamSubscription<String>>{};
  final Map<String, StreamSubscription<ChatPresenceEvent>> _webPresenceSubs =
      <String, StreamSubscription<ChatPresenceEvent>>{};
  final Map<String, StreamSubscription<ChatReceiptEvent>> _webReceiptSubs =
      <String, StreamSubscription<ChatReceiptEvent>>{};
  final Map<String, StreamSubscription<void>> _webConnectedSubs =
      <String, StreamSubscription<void>>{};
  final Map<String, DateTime> _webThreadInitialHistoryLoadedAt =
      <String, DateTime>{};
  final Map<String, DateTime> _webPresenceSnapshotSuppressUntil =
      <String, DateTime>{};
  final Map<String, Timer> _webThreadHistoryGapFillTimers =
      <String, Timer>{};
  final Map<String, Set<String>> _webReadReceiptSentIds =
      <String, Set<String>>{};
  String? _activeWebThreadKey;
  int _webLocalMessageCounter = 0;
  bool _wasActiveBottomBarTab = false;
  String? _lastEmbeddedRealtimeThreadIdsSig;

  /// Same logic as [ChatScreenViewModel._isDirectMessageFromMe]: peer id wins
  /// over profile id (profile can be wrong/stale).
  bool _webDmIsMine(String senderId, String peerTargetUserId) {
    final sender = senderId.trim();
    if (sender.isEmpty) return false;
    final peer = peerTargetUserId.trim();
    if (peer.isNotEmpty) {
      if (sender == peer) return false;
      return true;
    }
    final myId = (ProfileService().profile?.id ?? '').trim();
    return myId.isNotEmpty && sender == myId;
  }

  String _webDmReceiptUserId(String senderId, String peerTargetUserId) {
    if (_webDmIsMine(senderId, peerTargetUserId)) {
      return senderId.trim();
    }
    return (ProfileService().profile?.id ?? '').trim();
  }

  bool _webShouldEmitReadReceiptsNow() {
    final s = WidgetsBinding.instance.lifecycleState;
    return s == null || s == AppLifecycleState.resumed;
  }

  void _webSendReadReceiptOnce({
    required String key,
    required MatchChatService service,
    required String rawMessageId,
  }) {
    if (!mounted || !_webShouldEmitReadReceiptsNow()) return;
    final id = rawMessageId.trim();
    if (id.isEmpty) return;
    if (!identical(_webThreadServices[key], service)) return;
    final sent = _webReadReceiptSentIds.putIfAbsent(key, () => <String>{});
    if (sent.contains(id)) return;
    if (!service.sendReadReceipt(id)) return;
    sent.add(id);
  }

  void _webFlushReadReceiptsForThread(String key, MatchChatService service) {
    if (!mounted || !_webShouldEmitReadReceiptsNow()) return;
    if (!identical(_webThreadServices[key], service)) return;
    final list = _webThreadMessages[key];
    if (list == null) return;
    for (final m in list) {
      if (m.isMe) continue;
      final id = (m.messageId ?? '').trim();
      if (id.isEmpty) continue;
      _webSendReadReceiptOnce(key: key, service: service, rawMessageId: id);
    }
  }

  Future<void> _embeddedDisposeHook(String targetUserId) async {
    final id = targetUserId.trim();
    if (id.isEmpty) return;
    await _disposeWebThread('user:$id');
  }

  Future<void> _embeddedSyncHook() async {
    if (!mounted) return;
    await _syncEmbeddedThreadRealtime(_safeVm.threads);
  }

  Future<void> _disposeWebThreadsExcept(String? keepKey) async {
    for (final k in List<String>.from(_webThreadServices.keys)) {
      if (keepKey != null && k == keepKey) continue;
      await _disposeWebThread(k);
    }
  }

  Future<void> _pruneWebSocketsForThreadList(
    List<ChatThreadPreview> threads,
  ) async {
    final ids = <String>{
      for (final t in threads) (t.targetUserId ?? '').trim(),
    }..remove('');
    final stale = <String>[];
    for (final k in _webThreadServices.keys) {
      if (!k.startsWith('user:')) continue;
      final id = k.substring('user:'.length).trim();
      if (id.isEmpty || !ids.contains(id)) {
        stale.add(k);
      }
    }
    for (final k in stale) {
      await _disposeWebThread(k);
    }
  }

  Future<void> _syncWebDesktopSelectedSocketOnly() async {
    if (!mounted || !kIsWeb || !widget.embedInBottomBar) return;
    final w = MediaQuery.sizeOf(context).width;
    if (w < _webCompactBreakpoint) return;
    final sel = (_selectedWebTargetUserId ?? '').trim();
    if (sel.isEmpty) {
      await _disposeWebThreadsExcept(null);
      return;
    }
    final thread = _findThreadByTargetUserId(sel);
    if (thread == null) {
      await _disposeWebThreadsExcept(null);
      return;
    }
    final key = _threadKey(thread);
    await _disposeWebThreadsExcept(key);
    if (!_webThreadServices.containsKey(key)) {
      await _bindWebThread(thread);
    }
  }

  String _threadKey(ChatThreadPreview thread) {
    final targetUserId = (thread.targetUserId ?? '').trim();
    if (targetUserId.isNotEmpty) return 'user:$targetUserId';
    return 'name:${thread.userName.trim().toLowerCase()}';
  }

  ChatThreadPreview? _findThreadByTargetUserId(String? targetUserId) {
    final id = (targetUserId ?? '').trim();
    if (id.isEmpty) return null;
    for (final t in _safeVm.threads) {
      if ((t.targetUserId ?? '').trim() == id) return t;
    }
    return null;
  }

  Future<void> _pickAndOpenUser() async {
    final selected = await Navigator.pushNamed(
      context,
      RoutesName.allMemberScreen,
    );
    if (!mounted || selected is! ChatRouteArgs) return;
    final selectedName = selected.contactName.trim();
    final selectedTargetUserId = (selected.targetUserId ?? '').trim();
    if (selectedName.isEmpty || selectedTargetUserId.isEmpty) return;

    _safeVm.startOrOpenThread(
      selectedName,
      targetUserId: selectedTargetUserId,
      avatarUrl: selected.contactAvatarUrl,
    );
    _webThreadMessages.putIfAbsent(
      'user:$selectedTargetUserId',
      () => <WebChatMessageItem>[],
    );
    if (kIsWeb && widget.embedInBottomBar) {
      setState(() => _selectedWebTargetUserId = selectedTargetUserId);
      await _bindSelectedWebThread();
      return;
    }
    if (widget.embedInBottomBar) {
      await _openEmbeddedDirectChatFromRouteArgs(selected);
      return;
    }
    await Navigator.pushNamed(
      context,
      RoutesName.chatScreen,
      arguments: selected,
    );
  }

  Future<void> _bindSelectedWebThread() async {
    if (!kIsWeb || !widget.embedInBottomBar) return;
    final selected = _findThreadByTargetUserId(_selectedWebTargetUserId);
    if (selected == null) return;
    await _bindWebThread(selected);
  }

  Future<void> _consumePendingWebEmbeddedOpen(ChatRouteArgs pending) async {
    if (!mounted) return;
    final id = (pending.targetUserId ?? '').trim();
    if (id.isEmpty) return;
    _safeVm.startOrOpenThread(
      pending.contactName,
      targetUserId: id,
      avatarUrl: pending.contactAvatarUrl,
    );
    if (!kIsWeb || !widget.embedInBottomBar) return;
    setState(() => _selectedWebTargetUserId = id);
    await _bindSelectedWebThread();
  }

  void _upsertPreviewFromWebRealtime({
    required ChatThreadPreview thread,
    required String targetUserId,
    required RealtimeChatMessage msg,
    required bool isMine,
    bool isNewLiveMessage = true,
  }) {
    final selectedPeer = (_selectedWebTargetUserId ?? '').trim();
    final viewingThisThread =
        selectedPeer.isNotEmpty && selectedPeer == targetUserId;
    if (!isMine &&
        !kIsWeb &&
        isNewLiveMessage &&
        WidgetsBinding.instance.lifecycleState != null &&
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      final title = msg.senderName.trim().isNotEmpty
          ? msg.senderName.trim()
          : thread.userName.trim().isNotEmpty
              ? thread.userName.trim()
              : AppText.sportFinding;
      final raw = msg.content.trim();
      if (raw.isNotEmpty) {
        final body = raw.length > 120 ? '${raw.substring(0, 117)}...' : raw;
        unawaited(
          FcmLocalNotifications.showSimple(
            title: title,
            body: body,
            payload: <String, dynamic>{
              'type': 'direct_chat',
              'sender_id': msg.senderId,
              'target_user_id': targetUserId,
              'message_id': msg.messageId,
            },
          ),
        );
      }
    }
    if (!isMine && !viewingThisThread) {
      ChatListScreenViewModel.incrementUnread(
        userName: thread.userName,
        targetUserId: thread.targetUserId,
        avatarUrl: thread.avatarUrl,
        lastMessage: msg.content,
        lastAt: msg.sentAt,
      );
    } else {
      ChatListScreenViewModel.upsertThread(
        userName: thread.userName,
        targetUserId: thread.targetUserId,
        avatarUrl: thread.avatarUrl,
        lastMessage: msg.content,
        lastAt: msg.sentAt,
        unreadCount: (!isMine && viewingThisThread) ? 0 : null,
      );
    }
  }

  void _safeWebSetState() {
    if (!mounted) return;
    if (kIsWeb) {
      // Defer: synchronous setState from WS streams can run while the web
      // EngineFlutterView is tearing down, triggering !isDisposed asserts.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !context.mounted) return;
        try {
          setState(() {});
        } catch (_) {}
      });
      return;
    }
    try {
      setState(() {});
    } catch (_) {}
  }

  Future<void> _bindWebThread(ChatThreadPreview thread) async {
    final targetUserId = (thread.targetUserId ?? '').trim();
    if (targetUserId.isEmpty) return;
    final key = _threadKey(thread);

    if (kIsWeb && widget.embedInBottomBar && mounted) {
      final w = MediaQuery.sizeOf(context).width;
      if (w >= _webCompactBreakpoint) {
        await _disposeWebThreadsExcept(key);
      }
    }

    if (_webThreadServices.containsKey(key)) return;

    final token = await AppPreferences.getAccessToken();
    if (token == null || token.isEmpty) return;
    if (!mounted) return;
    if (ChatListRealtimeCoordinator.matchesFullscreen(targetUserId)) return;

    final service = MatchChatService(accessToken: token, targetUserId: targetUserId);
    _webThreadServices[key] = service;

    if (mounted && kIsWeb && widget.embedInBottomBar) {
      final width = MediaQuery.sizeOf(context).width;
      if (width >= _webCompactBreakpoint) {
        _activeWebThreadKey = key;
      }
    }

    try {
      final history = await service.loadHistory();
      if (!mounted || !identical(_webThreadServices[key], service)) {
        if (identical(_webThreadServices[key], service)) {
          unawaited(_disposeWebThread(key));
        } else {
          service.dispose();
        }
        return;
      }
      _webThreadInitialHistoryLoadedAt[key] = DateTime.now();
      final localizations = mounted ? MaterialLocalizations.of(context) : null;
      final list = _webThreadMessages.putIfAbsent(key, () => <WebChatMessageItem>[]);
      // Always replace with this REST page after a (re)bind. Previously we only
      // filled when the list was empty; switching threads disposed the socket but
      // left stale rows, so a fresh loadHistory() was ignored and new messages
      // (e.g. from mobile) never appeared until a lucky WS push.
      list.clear();
      final peerId = targetUserId.trim();
      final seenIds = <String>{};
      for (final item in history) {
        final rawId = item.messageId.trim();
        if (rawId.isNotEmpty && !seenIds.add(rawId)) {
          continue;
        }
        final isMeHist = _webDmIsMine(item.senderId, peerId);
        final rdDel = item.receiptTimesForUi(
          _webDmReceiptUserId(item.senderId, peerId),
        );
        list.add(
          WebChatMessageItem(
            text: item.content,
            time: localizations?.formatTimeOfDay(
                  TimeOfDay.fromDateTime(item.sentAt.toLocal()),
                ) ??
                '',
            isMe: isMeHist,
            messageId: rawId.isEmpty ? null : rawId,
            readAt: rdDel.$1,
            deliveredAt: rdDel.$2,
          ),
        );
      }
      if (mounted &&
          kIsWeb &&
          widget.embedInBottomBar &&
          MediaQuery.sizeOf(context).width >= _webCompactBreakpoint &&
          _activeWebThreadKey == key) {
        setState(() {});
      }
    } catch (_) {}

    if (!mounted || !identical(_webThreadServices[key], service)) {
      if (identical(_webThreadServices[key], service)) {
        unawaited(_disposeWebThread(key));
      } else {
        service.dispose();
      }
      return;
    }

    _webMessageSubs[key] = service.onMessage.listen((msg) {
      if (!mounted) return;
      final isMine = _webDmIsMine(msg.senderId, targetUserId);
      final receiptUserId = _webDmReceiptUserId(msg.senderId, targetUserId);
      final list = _webThreadMessages.putIfAbsent(key, () => <WebChatMessageItem>[]);
      final mid = msg.messageId.trim();

      // Backend sometimes emits the same chat_message twice; merge by id so we
      // don't duplicate rows or double-count sidebar previews.
      if (mid.isNotEmpty) {
        final dupIdx = list.indexWhere((m) => (m.messageId ?? '').trim() == mid);
        if (dupIdx >= 0) {
          final rdDel = msg.receiptTimesForUi(receiptUserId);
          final ex = list[dupIdx];
          list[dupIdx] = ex.copyWith(
            readAt: rdDel.$1 ?? ex.readAt,
            deliveredAt: rdDel.$2 ?? ex.deliveredAt,
            isPending: false,
            isFailed: false,
          );
          if (!isMine) {
            ChatListScreenViewModel.applyPresenceForUser(
              subjectUserId: targetUserId,
              status: 'online',
              sentAt: msg.sentAt.toUtc(),
            );
          }
          _upsertPreviewFromWebRealtime(
            thread: thread,
            targetUserId: targetUserId,
            msg: msg,
            isMine: isMine,
            isNewLiveMessage: false,
          );
          if (!isMine) {
            _webSendReadReceiptOnce(
              key: key,
              service: service,
              rawMessageId: mid,
            );
          }
          _safeWebSetState();
          return;
        }
      }

      if (isMine) {
        final rdDelMine = msg.receiptTimesForUi(receiptUserId);
        final pendingIndex = list.indexWhere(
          (item) => item.isMe && item.isPending && item.text.trim() == msg.content.trim(),
        );
        if (pendingIndex >= 0) {
          list[pendingIndex] = list[pendingIndex].copyWith(
            isPending: false,
            isFailed: false,
            messageId: msg.messageId.trim().isEmpty ? null : msg.messageId.trim(),
            readAt: rdDelMine.$1,
            deliveredAt: rdDelMine.$2,
            time: MaterialLocalizations.of(
              context,
            ).formatTimeOfDay(TimeOfDay.fromDateTime(msg.sentAt.toLocal())),
          );
        } else {
          list.add(
            WebChatMessageItem(
              text: msg.content,
              time: MaterialLocalizations.of(
                context,
              ).formatTimeOfDay(TimeOfDay.fromDateTime(msg.sentAt.toLocal())),
              isMe: true,
              messageId: msg.messageId.trim().isEmpty ? null : msg.messageId.trim(),
              readAt: rdDelMine.$1,
              deliveredAt: rdDelMine.$2,
            ),
          );
        }
      } else {
        ChatListScreenViewModel.applyPresenceForUser(
          subjectUserId: targetUserId,
          status: 'online',
          sentAt: msg.sentAt.toUtc(),
        );
        final rdDelPeer = msg.receiptTimesForUi(receiptUserId);
        list.add(
          WebChatMessageItem(
            text: msg.content,
            time: MaterialLocalizations.of(
              context,
            ).formatTimeOfDay(TimeOfDay.fromDateTime(msg.sentAt.toLocal())),
            isMe: false,
            messageId: msg.messageId.trim().isEmpty ? null : msg.messageId.trim(),
            readAt: rdDelPeer.$1,
            deliveredAt: rdDelPeer.$2,
          ),
        );
      }
      if (!isMine && mid.isNotEmpty) {
        _webSendReadReceiptOnce(
          key: key,
          service: service,
          rawMessageId: mid,
        );
      }
      _upsertPreviewFromWebRealtime(
        thread: thread,
        targetUserId: targetUserId,
        msg: msg,
        isMine: isMine,
      );
      _safeWebSetState();
    });
    _webErrorSubs[key] = service.onError.listen((_) {});
    _webPresenceSubs[key] = service.onPresence.listen((ChatPresenceEvent e) {
      final peerId = (thread.targetUserId ?? '').trim();
      if (peerId.isEmpty) return;
      final myId = ProfileService().profile?.id.trim() ?? '';
      if (myId.isNotEmpty && e.userId.trim() == myId) return;
      if (e.userId.trim() != peerId) return;
      final st = e.status.trim().toLowerCase();
      final nowOnline =
          st == 'online' || st == 'active' || st == 'available';
      if (nowOnline) {
        _webPresenceSnapshotSuppressUntil.remove(key);
      } else {
        final until = _webPresenceSnapshotSuppressUntil[key];
        if (e.fromSnapshot &&
            until != null &&
            DateTime.now().isBefore(until)) {
          return;
        }
      }
      ChatListScreenViewModel.applyPresenceForUser(
        subjectUserId: peerId,
        status: e.status,
        sentAt: e.sentAt,
      );
      _safeWebSetState();
    });
    _webReceiptSubs[key] = service.onReceipt.listen((ChatReceiptEvent r) {
      final mid = r.messageId.trim();
      if (mid.isEmpty) return;
      final list = _webThreadMessages[key];
      if (list == null) return;
      final idx = list.indexWhere((m) => (m.messageId ?? '').trim() == mid);
      if (idx < 0) return;
      final at = r.at ?? DateTime.now().toUtc();
      if (r.kind == 'read') {
        list[idx] = list[idx].copyWith(readAt: at);
      } else if (r.kind == 'delivered') {
        list[idx] = list[idx].copyWith(deliveredAt: at);
      } else {
        return;
      }
      _safeWebSetState();
    });
    _webConnectedSubs[key] = service.onConnected.listen((_) {
      _webPresenceSnapshotSuppressUntil[key] =
          DateTime.now().add(const Duration(seconds: 4));
      _webFlushReadReceiptsForThread(key, service);
      _startWebThreadHistoryGapFillTimer(
        key: key,
        thread: thread,
        targetUserId: targetUserId,
        service: service,
      );
      // One catch-up merge shortly after connect: initial GET can race with a
      // message just persisted on another device (no WS push yet).
      unawaited(
        Future<void>.delayed(const Duration(seconds: 2), () async {
          if (!mounted || !identical(_webThreadServices[key], service)) return;
          final t = _findThreadByTargetUserId(targetUserId) ?? thread;
          await _mergeWebThreadHistoryAfterWsConnect(
            key: key,
            thread: t,
            targetUserId: targetUserId,
            service: service,
          );
        }),
      );
    });
    service.connect();
  }

  void _startWebThreadHistoryGapFillTimer({
    required String key,
    required ChatThreadPreview thread,
    required String targetUserId,
    required MatchChatService service,
  }) {
    _webThreadHistoryGapFillTimers.remove(key)?.cancel();
    _webThreadHistoryGapFillTimers[key] = Timer.periodic(
      _webHistoryGapFillInterval,
      (_) {
        if (!mounted) return;
        if (!identical(_webThreadServices[key], service)) return;
        final t = _findThreadByTargetUserId(targetUserId) ?? thread;
        unawaited(
          _mergeWebThreadHistoryAfterWsConnect(
            key: key,
            thread: t,
            targetUserId: targetUserId,
            service: service,
          ),
        );
      },
    );
  }

  /// Fetches REST history on a timer while the WS is up and appends any
  /// message ids not already in the pane (covers missed pushes; live dual
  /// delivery still needs the server to emit to both sockets).
  Future<void> _mergeWebThreadHistoryAfterWsConnect({
    required String key,
    required ChatThreadPreview thread,
    required String targetUserId,
    required MatchChatService service,
  }) async {
    if (!mounted) return;
    final anchor = _webThreadInitialHistoryLoadedAt[key];
    if (anchor != null &&
        DateTime.now().difference(anchor) < const Duration(seconds: 1)) {
      return;
    }
    try {
      final history = await service.loadHistory();
      if (!mounted || !identical(_webThreadServices[key], service)) return;
      final list = _webThreadMessages.putIfAbsent(key, () => <WebChatMessageItem>[]);
      final existing = <String>{
        for (final m in list)
          if ((m.messageId ?? '').trim().isNotEmpty) (m.messageId ?? '').trim(),
      };
      final peerId = targetUserId.trim();
      final localizations = MaterialLocalizations.of(context);
      var added = false;
      RealtimeChatMessage? lastMerged;
      for (final item in history) {
        final rawId = item.messageId.trim();
        if (rawId.isEmpty) continue;
        if (existing.contains(rawId)) continue;
        existing.add(rawId);
        final isMeHist = _webDmIsMine(item.senderId, peerId);
        final rdDel = item.receiptTimesForUi(
          _webDmReceiptUserId(item.senderId, peerId),
        );
        list.add(
          WebChatMessageItem(
            text: item.content,
            time: localizations.formatTimeOfDay(
              TimeOfDay.fromDateTime(item.sentAt.toLocal()),
            ),
            isMe: isMeHist,
            messageId: rawId,
            readAt: rdDel.$1,
            deliveredAt: rdDel.$2,
          ),
        );
        lastMerged = item;
        added = true;
      }
      if (lastMerged != null) {
        final isMine = _webDmIsMine(lastMerged.senderId, peerId);
        _upsertPreviewFromWebRealtime(
          thread: thread,
          targetUserId: targetUserId,
          msg: lastMerged,
          isMine: isMine,
          isNewLiveMessage: false,
        );
      }
      if (added) {
        _webFlushReadReceiptsForThread(key, service);
        _safeWebSetState();
      }
    } catch (_) {}
  }

  Future<void> _disposeWebThread(String key) async {
    await _webMessageSubs.remove(key)?.cancel();
    await _webErrorSubs.remove(key)?.cancel();
    await _webPresenceSubs.remove(key)?.cancel();
    await _webReceiptSubs.remove(key)?.cancel();
    await _webConnectedSubs.remove(key)?.cancel();
    _webThreadHistoryGapFillTimers.remove(key)?.cancel();
    _webThreadInitialHistoryLoadedAt.remove(key);
    _webPresenceSnapshotSuppressUntil.remove(key);
    _webReadReceiptSentIds.remove(key);
    _webThreadMessages.remove(key);
    _webThreadServices.remove(key)?.dispose();
  }

  Future<void> _syncEmbeddedThreadRealtime(List<ChatThreadPreview> threads) async {
    await _pruneWebSocketsForThreadList(threads);

    final activeFullscreen =
        (ChatListRealtimeCoordinator.fullScreenDirectTargetUserId ?? '').trim();
    final activeFullscreenKey =
        activeFullscreen.isEmpty ? null : 'user:$activeFullscreen';
    if (activeFullscreenKey != null &&
        _webThreadServices.containsKey(activeFullscreenKey)) {
      await _disposeWebThread(activeFullscreenKey);
    }

    if (!widget.embedInBottomBar || !mounted) return;

    if (!kIsWeb) {
      await _disposeWebThreadsExcept(null);
      return;
    }

    final w = MediaQuery.sizeOf(context).width;
    if (w < _webCompactBreakpoint) {
      await _disposeWebThreadsExcept(null);
      return;
    }

    await _syncWebDesktopSelectedSocketOnly();
  }

  Future<void> _openEmbeddedDirectChat(ChatThreadPreview t) async {
    final id = (t.targetUserId ?? '').trim();
    final args = ChatRouteArgs(
      contactName: t.userName,
      targetUserId: t.targetUserId,
      isOnline: t.isOnline,
      contactAvatarUrl: t.avatarUrl,
    );
    if (kIsWeb &&
        widget.embedInBottomBar &&
        MediaQuery.sizeOf(context).width >= _webCompactBreakpoint &&
        id.isNotEmpty) {
      await _disposeWebThread(_threadKey(t));
      if (!mounted) return;
      _safeVm.startOrOpenThread(
        t.userName,
        targetUserId: id,
        avatarUrl: t.avatarUrl,
      );
      setState(() => _selectedWebTargetUserId = id);
      ChatListScreenViewModel.markRead(
        userName: t.userName,
        targetUserId: t.targetUserId,
      );
      await _bindSelectedWebThread();
      await _embeddedSyncHook();
      return;
    }
    if (id.isNotEmpty) {
      await _disposeWebThread(_threadKey(t));
      ChatListRealtimeCoordinator.beginFullScreenDirectChat(id);
    }
    try {
      if (!mounted) return;
      await Navigator.pushNamed(
        context,
        RoutesName.chatScreen,
        arguments: args,
      );
    } finally {
      if (id.isNotEmpty) {
        ChatListRealtimeCoordinator.endFullScreenDirectChat(id);
      }
      await _embeddedSyncHook();
    }
  }

  Future<void> _openEmbeddedDirectChatFromRouteArgs(ChatRouteArgs selected) async {
    final id = (selected.targetUserId ?? '').trim();
    if (kIsWeb &&
        widget.embedInBottomBar &&
        MediaQuery.sizeOf(context).width >= _webCompactBreakpoint &&
        id.isNotEmpty) {
      await _disposeWebThread('user:$id');
      if (!mounted) return;
      _safeVm.startOrOpenThread(
        selected.contactName,
        targetUserId: id,
        avatarUrl: selected.contactAvatarUrl,
      );
      setState(() => _selectedWebTargetUserId = id);
      ChatListScreenViewModel.markRead(
        userName: selected.contactName,
        targetUserId: id,
      );
      await _bindSelectedWebThread();
      await _embeddedSyncHook();
      return;
    }
    if (id.isNotEmpty) {
      await _disposeWebThread('user:$id');
      ChatListRealtimeCoordinator.beginFullScreenDirectChat(id);
    }
    try {
      if (!mounted) return;
      await Navigator.pushNamed(
        context,
        RoutesName.chatScreen,
        arguments: selected,
      );
    } finally {
      if (id.isNotEmpty) {
        ChatListRealtimeCoordinator.endFullScreenDirectChat(id);
      }
      await _embeddedSyncHook();
    }
  }

  Future<void> _catchUpOpenWebThreadsOnResume() async {
    if (!mounted || _webThreadServices.isEmpty) return;
    for (final entry in Map<String, MatchChatService>.from(_webThreadServices)
        .entries) {
      final key = entry.key;
      final service = entry.value;
      if (!key.startsWith('user:')) continue;
      final targetUserId = key.substring('user:'.length).trim();
      if (targetUserId.isEmpty) continue;
      final thread = _findThreadByTargetUserId(targetUserId);
      if (thread == null) continue;
      await _mergeWebThreadHistoryAfterWsConnect(
        key: key,
        thread: thread,
        targetUserId: targetUserId,
        service: service,
      );
      if (!mounted) return;
      _webFlushReadReceiptsForThread(key, service);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.embedInBottomBar) {
      ChatListRealtimeCoordinator.disposeListSocketForTargetUser =
          _embeddedDisposeHook;
      ChatListRealtimeCoordinator.syncEmbeddedListRealtimeNow = _embeddedSyncHook;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeVm.refreshDirectChats();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) return;
    unawaited(_catchUpOpenWebThreadsOnResume());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.embedInBottomBar) {
      if (identical(
            ChatListRealtimeCoordinator.disposeListSocketForTargetUser,
            _embeddedDisposeHook,
          )) {
        ChatListRealtimeCoordinator.disposeListSocketForTargetUser = null;
      }
      if (identical(
            ChatListRealtimeCoordinator.syncEmbeddedListRealtimeNow,
            _embeddedSyncHook,
          )) {
        ChatListRealtimeCoordinator.syncEmbeddedListRealtimeNow = null;
      }
    }
    _webMessageController.dispose();
    _searchController.dispose();
    for (final sub in _webMessageSubs.values) {
      sub.cancel();
    }
    for (final sub in _webErrorSubs.values) {
      sub.cancel();
    }
    for (final sub in _webPresenceSubs.values) {
      sub.cancel();
    }
    for (final sub in _webReceiptSubs.values) {
      sub.cancel();
    }
    for (final t in _webThreadHistoryGapFillTimers.values) {
      t.cancel();
    }
    _webThreadHistoryGapFillTimers.clear();
    for (final service in _webThreadServices.values) {
      service.dispose();
    }
    _webThreadServices.clear();
    _webThreadMessages.clear();
    _webReadReceiptSentIds.clear();
    super.dispose();
  }

  Widget _buildMobileContent({
    required BuildContext context,
    required ChatListScreenViewModel model,
    required List<ChatThreadPreview> filteredThreads,
  }) {
    return MainFrame(
      showDecorationLayer: !widget.embedInBottomBar,
      child: Column(
        children: [
          if (!widget.embedInBottomBar)
            Padding(
              padding: context.padSym(h: 20),
              child: AppBarWidget(
                onTapFirst: () => Navigator.pop(context),
                title: AppText.sportFinding,
              ),
            ),
          Expanded(
            child:
                (model.hasThreads || _searchController.text.trim().isNotEmpty)
                    ? Column(
                        children: [
                          Padding(
                            padding: context.padSym(h: 20, v: 8),
                            child: SearchBarWidget(
                              isShow: false,
                              controller: _searchController,
                              hintText: 'Search chats...',
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          Expanded(
                            child: filteredThreads.isNotEmpty
                                ? ListView.separated(
                                    padding: context.padSym(h: 20, v: 8),
                                    itemCount: filteredThreads.length,
                                    separatorBuilder: (_, _) =>
                                        SizedBox(height: context.h(10)),
                                    itemBuilder: (context, index) {
                                      final t = filteredThreads[index];
                                      final targetUserId =
                                          (t.targetUserId ?? '').trim();
                                      final canDelete = targetUserId.isNotEmpty;

                                      Widget row = GestureDetector(
                                        onTap: () async {
                                          if (widget.embedInBottomBar) {
                                            await _openEmbeddedDirectChat(t);
                                          } else {
                                            await Navigator.pushNamed(
                                              context,
                                              RoutesName.chatScreen,
                                              arguments: ChatRouteArgs(
                                                contactName: t.userName,
                                                targetUserId: t.targetUserId,
                                                isOnline: t.isOnline,
                                                contactAvatarUrl: t.avatarUrl,
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: context.padSym(
                                            h: 12,
                                            v: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context.appColors.blue10,
                                            borderRadius:
                                                BorderRadius.circular(
                                              context.radius(12),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  CircleAvatar(
                                                    radius: context.radius(22),
                                                    backgroundColor: context
                                                        .appColors.greylight,
                                                    child: (t.avatarUrl ?? '')
                                                            .trim()
                                                            .isNotEmpty
                                                        ? ClipOval(
                                                            child: Image.network(
                                                              t.avatarUrl!.trim(),
                                                              width: context.w(44),
                                                              height: context.w(44),
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Center(
                                                                  child: Text(
                                                                    t.userName
                                                                            .isNotEmpty
                                                                        ? t.userName[0]
                                                                            .toUpperCase()
                                                                        : 'U',
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          )
                                                        : Text(
                                                            t.userName.isNotEmpty
                                                                ? t.userName[0]
                                                                    .toUpperCase()
                                                                : 'U',
                                                          ),
                                                  ),
                                                  if (t.isOnline)
                                                    Positioned(
                                                      right: 0,
                                                      bottom: 0,
                                                      child: Container(
                                                        width: context.w(10),
                                                        height: context.w(10),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFF25D366,
                                                          ),
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                            color: Colors.white,
                                                            width: 1.5,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              SizedBox(width: context.w(12)),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    NormalText(
                                                      titleText: t.userName,
                                                      subText: t.lastMessage,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: context.h(2)),
                                                    Text(
                                                      () {
                                                        if (t.isOnline) {
                                                          return 'Online';
                                                        }
                                                        final iso =
                                                            (t.lastSeenIso ?? '')
                                                                .trim();
                                                        if (iso.isEmpty) {
                                                          return 'Offline';
                                                        }
                                                        final parsed =
                                                            DateTime.tryParse(iso);
                                                        if (parsed == null) {
                                                          return 'Offline';
                                                        }
                                                        return 'Last seen ${DateTimeFormatters.relativeLabel(parsed.toLocal())}';
                                                      }(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: context.appText.text12W400
                                                          .copyWith(
                                                        fontSize: context.text(10),
                                                        color: context
                                                            .appColors.greylight,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: context.w(8)),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    t.lastTime,
                                                    style: context.appText.text12W500
                                                        .copyWith(
                                                      color: context
                                                          .appColors.greylight,
                                                    ),
                                                  ),
                                                  if (t.unreadCount > 0) ...[
                                                    SizedBox(height: context.h(4)),
                                                    Container(
                                                      padding: context.padSym(
                                                        h: 7,
                                                        v: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: context
                                                            .appColors.primary,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                          999,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        t.unreadCount > 99
                                                            ? '99+'
                                                            : '${t.unreadCount}',
                                                        style: context.appText.text12W500
                                                            .copyWith(
                                                          color: context
                                                              .appColors.onPrimary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                      if (!canDelete) return row;
                                      return Dismissible(
                                        key: ValueKey(
                                          'chat_thread_${t.targetUserId}_${t.userName}',
                                        ),
                                        direction: DismissDirection.endToStart,
                                        confirmDismiss: (_) async {
                                          final confirmed =
                                              await showAppDialog<bool>(
                                            context,
                                            title: 'Delete chat?',
                                            message:
                                                'This will remove the chat thread locally.',
                                            actions: [
                                              AppDialogAction(
                                                label: 'Cancel',
                                                onPressed: (ctx) =>
                                                    Navigator.of(ctx).pop(false),
                                              ),
                                              AppDialogAction(
                                                label: 'Delete',
                                                isDestructive: true,
                                                onPressed: (ctx) =>
                                                    Navigator.of(ctx).pop(true),
                                              ),
                                            ],
                                          );
                                          return confirmed == true;
                                        },
                                        onDismissed: (_) {
                                          ChatListScreenViewModel.removeThread(
                                            targetUserId: t.targetUserId,
                                            userName: t.userName,
                                          );
                                          ChatScreenMessagesCache.invalidate(
                                            (t.targetUserId ?? '').trim(),
                                          );
                                          setState(() {});
                                        },
                                        background: Container(
                                          alignment: Alignment.centerRight,
                                          padding: context.padSym(h: 16),
                                          decoration: BoxDecoration(
                                            color: context.appColors.error,
                                            borderRadius:
                                                BorderRadius.circular(
                                              context.radius(12),
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.delete_outline_rounded,
                                            color: context.appColors.onPrimary,
                                          ),
                                        ),
                                        child: row,
                                      );
                                    },
                                  )
                                : Center(
                                    child: Text(
                                      'No chats found.',
                                      style: context.appText.text14W400.copyWith(
                                        color: context.appColors.greylight,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          'No chats yet.',
                          style: context.appText.text14W400.copyWith(
                            color: context.appColors.greylight,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomBarSelectedIndex =
        widget.embedInBottomBar
            ? context.select<BottomBarScreenViewModel, int>(
                (vm) => vm.selectedIndex,
              )
            : null;
    final isActiveTab = bottomBarSelectedIndex == _chatTabIndex;

    if (widget.embedInBottomBar && _wasActiveBottomBarTab && !isActiveTab) {
      // Tab changed away from Chat; clear ephemeral UI state.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_disposeWebThreadsExcept(null));
        _searchController.clear();
        _webMessageController.clear();
        if (_selectedWebTargetUserId != null) {
          setState(() {
            _selectedWebTargetUserId = null;
            _activeWebThreadKey = null;
          });
        } else {
          setState(() {});
        }
      });
    }
    if (widget.embedInBottomBar) {
      _wasActiveBottomBarTab = isActiveTab;
    }

    return ChangeNotifierProvider.value(
      value: _safeVm,
      child: Consumer<ChatListScreenViewModel>(
        builder: (context, model, _) {
          if (kIsWeb && widget.embedInBottomBar && isActiveTab) {
            final pending = WebEmbeddedChatOpenCoordinator.takePending();
            if (pending != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _consumePendingWebEmbeddedOpen(pending);
              });
            }
          }
          // Inbox uses REST; optional single list-level DM socket only for web
          // split-view (selected thread). Mobile relies on FCM + open-chat WS.
          if (widget.embedInBottomBar) {
            final ids = <String>{
              for (final t in model.threads) (t.targetUserId ?? '').trim(),
            }..remove('');
            final sig = ids.join('\u001f');
            if (sig != _lastEmbeddedRealtimeThreadIdsSig) {
              _lastEmbeddedRealtimeThreadIdsSig = sig;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!mounted || !context.mounted) return;
                await _syncEmbeddedThreadRealtime(model.threads);
              });
            }
          }

          final query = _searchController.text.trim().toLowerCase();
          final allThreads = model.threads;
          final List<ChatThreadPreview> filteredThreads = <ChatThreadPreview>[];
          for (var i = 0; i < allThreads.length; i++) {
            final t = allThreads[i];
            if (_webUnreadOnly && t.unreadCount <= 0) continue;
            if (query.isEmpty) {
              filteredThreads.add(t);
              continue;
            }
            final haystack =
                '${t.userName} ${t.lastMessage}'.toLowerCase();
            if (haystack.contains(query)) {
              filteredThreads.add(t);
            }
          }

          final filteredSelectedIndex = _selectedWebTargetUserId == null
              ? null
              : filteredThreads.indexWhere(
                  (t) =>
                      (t.targetUserId ?? '').trim() ==
                      (_selectedWebTargetUserId ?? '').trim(),
                );

          final Widget content = (kIsWeb && widget.embedInBottomBar)
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < _webCompactBreakpoint) {
                      return _buildMobileContent(
                        context: context,
                        model: model,
                        filteredThreads: filteredThreads,
                      );
                    }
                    return WebChatContent(
                  model: model,
                  threads: filteredThreads,
                  selectedThreadIndex:
                      (filteredSelectedIndex != null &&
                              filteredSelectedIndex >= 0)
                          ? filteredSelectedIndex
                          : null,
                  activeMessages:
                      (_selectedWebTargetUserId != null)
                          ? List<WebChatMessageItem>.unmodifiable(
                              _webThreadMessages[
                                    'user:${(_selectedWebTargetUserId ?? '').trim()}'
                                  ] ??
                                  const <WebChatMessageItem>[],
                            )
                          : const <WebChatMessageItem>[],
                  messageController: _webMessageController,
                  searchController: _searchController,
                  onSearchChanged: (_) => setState(() {}),
                  searchQuery: _searchController.text,
                  showUnreadOnly: _webUnreadOnly,
                  onUnreadToggle: (v) => setState(() => _webUnreadOnly = v),
                  onThreadSelected: (index) {
                    final selected = (index != null &&
                            index >= 0 &&
                            index < filteredThreads.length)
                        ? filteredThreads[index]
                        : null;
                    setState(() => _selectedWebTargetUserId = selected?.targetUserId);
                    if (selected != null) {
                      ChatListScreenViewModel.markRead(
                        userName: selected.userName,
                        targetUserId: selected.targetUserId,
                      );
                    }
                    _bindSelectedWebThread();
                  },
                  onPickUser: _pickAndOpenUser,
                  onClearChat: () {
                    final thread =
                        _findThreadByTargetUserId(_selectedWebTargetUserId);
                    if (thread != null) {
                      _webThreadMessages[_threadKey(thread)]?.clear();
                      ChatListScreenViewModel.recordThreadClearedLocally(
                        userName: thread.userName,
                        targetUserId: thread.targetUserId,
                      );
                      ChatScreenMessagesCache.invalidate(
                        (thread.targetUserId ?? '').trim(),
                      );
                    }
                    _webMessageController.clear();
                    unawaited(_disposeWebThreadsExcept(null));
                    setState(() {
                      _selectedWebTargetUserId = null;
                      _activeWebThreadKey = null;
                    });
                  },
                  onDeleteChat: () {
                    final thread =
                        _findThreadByTargetUserId(_selectedWebTargetUserId);
                    if (thread == null) return;
                    _webThreadMessages.remove(_threadKey(thread));
                    _disposeWebThread(_threadKey(thread));
                    ChatListScreenViewModel.removeThread(
                      targetUserId: thread.targetUserId,
                      userName: thread.userName,
                    );
                    ChatScreenMessagesCache.invalidate(
                      (thread.targetUserId ?? '').trim(),
                    );
                    _webMessageController.clear();
                    setState(() {
                      _selectedWebTargetUserId = null;
                      _activeWebThreadKey = null;
                    });
                  },
                  onSendMessage: () {
                    if (!model.hasThreads) return;
                    final activeThread =
                        _findThreadByTargetUserId(_selectedWebTargetUserId);
                    if (activeThread == null) return;
                    final text = _webMessageController.text.trim();
                    if (text.isEmpty) return;
                    final now = DateTime.now();
                    final key = _threadKey(activeThread);
                    _bindWebThread(activeThread);
                    final list = _webThreadMessages.putIfAbsent(
                      key,
                      () => <WebChatMessageItem>[],
                    );
                    _webLocalMessageCounter += 1;
                    final localId =
                        'web_local_${_webLocalMessageCounter}_${now.microsecondsSinceEpoch}';
                    list.add(
                      WebChatMessageItem(
                        text: text,
                        time: MaterialLocalizations.of(
                          context,
                        ).formatTimeOfDay(TimeOfDay.fromDateTime(now)),
                        isMe: true,
                        isPending: true,
                        localId: localId,
                      ),
                    );
                    final sent =
                        _webThreadServices[key]?.sendMessage(text) ?? false;
                    if (!sent) {
                      final index = list.indexWhere(
                        (item) => item.localId == localId,
                      );
                      if (index >= 0) {
                        list[index] = list[index].copyWith(
                          isPending: false,
                          isFailed: true,
                        );
                      }
                    }
                    ChatListScreenViewModel.upsertThread(
                      userName: activeThread.userName,
                      targetUserId: activeThread.targetUserId,
                      lastMessage: text,
                      lastAt: now,
                    );
                    _webMessageController.clear();
                    setState(() {});
                  },
                );
                  },
                )
              : MainFrame(
              showDecorationLayer: !widget.embedInBottomBar,
               child: Column(
                children: [
                  if (!widget.embedInBottomBar)
                    Padding(
                      padding: context.padSym(h: 20),
                      child: AppBarWidget(
                        onTapFirst: () => Navigator.pop(context),
                        title: AppText.sportFinding,
                      ),
                    ),
                  Expanded(
                    child: (model.hasThreads ||
                            _searchController.text.trim().isNotEmpty)
                        ? Column(
                            children: [
                              Padding(
                                padding: context.padSym(h: 20, v: 8),
                                child: SearchBarWidget(
                                  isShow: false,
                                  controller: _searchController,
                                  hintText: 'Search chats...',
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              Expanded(
                                child: filteredThreads.isNotEmpty
                                    ? ListView.separated(
                                        padding: context.padSym(h: 20, v: 8),
                                        itemCount: filteredThreads.length,
                                        separatorBuilder: (_, _) =>
                                            SizedBox(height: context.h(10)),
                                        itemBuilder: (context, index) {
                                          final t = filteredThreads[index];
                                          final targetUserId =
                                              (t.targetUserId ?? '').trim();
                                          final canDelete = targetUserId.isNotEmpty;

                                          Widget row = GestureDetector(
                                            onTap: () async {
                                              if (widget.embedInBottomBar) {
                                                await _openEmbeddedDirectChat(t);
                                              } else {
                                                await Navigator.pushNamed(
                                                  context,
                                                  RoutesName.chatScreen,
                                                  arguments: ChatRouteArgs(
                                                    contactName: t.userName,
                                                    targetUserId: t.targetUserId,
                                                    isOnline: t.isOnline,
                                                    contactAvatarUrl: t.avatarUrl,
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding: context.padSym(
                                                h: 12,
                                                v: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                color: context.appColors.blue10,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  context.radius(12),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: context.radius(22),
                                                    backgroundColor: context
                                                        .appColors.greylight,
                                                    child: (t.avatarUrl ?? '')
                                                            .trim()
                                                            .isNotEmpty
                                                        ? ClipOval(
                                                            child: Image.network(
                                                              t.avatarUrl!.trim(),
                                                              width: context.w(44),
                                                              height: context.w(44),
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Center(
                                                                  child: Text(
                                                                    t.userName
                                                                            .isNotEmpty
                                                                        ? t.userName[
                                                                                0]
                                                                            .toUpperCase()
                                                                        : 'U',
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          )
                                                        : Text(
                                                            t.userName.isNotEmpty
                                                                ? t.userName[0]
                                                                    .toUpperCase()
                                                                : 'U',
                                                          ),
                                                  ),
                                                  SizedBox(width: context.w(12)),
                                                  Expanded(
                                                    child: NormalText(
                                                      titleText: t.userName,
                                                      subText: t.lastMessage,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(width: context.w(8)),
                                                  Text(
                                                    t.lastTime,
                                                    style: context
                                                        .appText
                                                        .text12W500
                                                        .copyWith(
                                                          color: context
                                                              .appColors
                                                              .greylight,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );

                                          if (!canDelete) return row;

                                          return Dismissible(
                                            key: ValueKey<String>(
                                              'chat-$targetUserId',
                                            ),
                                            direction: DismissDirection.endToStart,
                                            confirmDismiss: (_) async {
                                              final ok = await showAppDialog<bool>(
                                                context,
                                                title: 'Delete chat?',
                                                message:
                                                    'Remove conversation with ${t.userName} from your chat list?',
                                                barrierDismissible: true,
                                                actions: [
                                                  AppDialogAction(
                                                    label: 'Cancel',
                                                    onPressed: (dialogContext) =>
                                                        Navigator.pop(dialogContext, false),
                                                  ),
                                                  AppDialogAction(
                                                    label: 'Delete',
                                                    isDestructive: true,
                                                    onPressed: (dialogContext) =>
                                                        Navigator.pop(dialogContext, true),
                                                  ),
                                                ],
                                              );
                                              return ok ?? false;
                                            },
                                            onDismissed: (_) async {
                                              try {
                                                await model.deleteConversation(
                                                  targetUserId: targetUserId,
                                                );
                                              } catch (e) {
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Failed to delete: $e',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            background: Container(
                                              padding: context.padSym(h: 16),
                                              alignment: Alignment.centerRight,
                                              decoration: BoxDecoration(
                                                color: context.appColors.error,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  context.radius(12),
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                              ),
                                            ),
                                            child: row,
                                          );
                                        },
                                      )
                                    : Center(
                                        child: Text(
                                          'No data found',
                                          style: context.appText.text14W400
                                              .copyWith(
                                            color: context.appColors.greylight,
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                padding: context.padSym(h: 20),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                    maxHeight: constraints.maxHeight,
                                    minWidth: constraints.maxWidth,
                                    maxWidth: constraints.maxWidth,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.invitedPeopleIcon,
                                        fit: BoxFit.scaleDown,
                                      ),
                                      SizedBox(height: context.h(20)),
                                      NormalText(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        titleText: AppText.players,
                                        titleAlign: TextAlign.center,
                                        subAlign: TextAlign.center,
                                        subText: AppText
                                            .discoverNearbyPeopleInYourArea,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );

          if (widget.embedInBottomBar) {
            // BottomBarScreen supplies the Scaffold + chat-tab FAB.
            return content;
          }

          return Scaffold(
            body: content,
            floatingActionButton: FloatingActionButton(
              onPressed: _pickAndOpenUser,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }
}
