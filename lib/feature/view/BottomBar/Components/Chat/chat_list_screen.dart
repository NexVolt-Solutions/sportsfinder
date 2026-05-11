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
import 'package:sport_finding/core/Network/match_chat_service.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_list_screen_view_model.dart';
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

class _ChatListScreenState extends State<ChatListScreen> {
  static const int _chatTabIndex = 3;
  static const double _webCompactBreakpoint = 980;

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
  String? _activeWebThreadKey;
  int _webLocalMessageCounter = 0;
  bool _wasActiveBottomBarTab = false;
  String? _lastEmbeddedRealtimeThreadIdsSig;

  Future<void> _embeddedDisposeHook(String targetUserId) async {
    final id = targetUserId.trim();
    if (id.isEmpty) return;
    await _disposeWebThread('user:$id');
  }

  Future<void> _embeddedSyncHook() async {
    if (!mounted) return;
    if (!_useEmbeddedListRealtimeLayout(context)) return;
    await _syncEmbeddedThreadRealtime(_safeVm.threads);
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

  Future<void> _bindWebThread(ChatThreadPreview thread) async {
    final targetUserId = (thread.targetUserId ?? '').trim();
    if (targetUserId.isEmpty) return;
    final key = _threadKey(thread);

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
      final localizations = mounted ? MaterialLocalizations.of(context) : null;
      final list = _webThreadMessages.putIfAbsent(key, () => <WebChatMessageItem>[]);
      if (list.isEmpty) {
        final myId = ProfileService().profile?.id.trim() ?? '';
        for (final item in history) {
          list.add(
            WebChatMessageItem(
              text: item.content,
              time: localizations?.formatTimeOfDay(
                    TimeOfDay.fromDateTime(item.sentAt.toLocal()),
                  ) ??
                  '',
              isMe: myId.isNotEmpty && item.senderId.trim() == myId,
              messageId: item.messageId.trim().isEmpty ? null : item.messageId.trim(),
              readAt: item.readAt,
              deliveredAt: item.deliveredAt,
            ),
          );
        }
      }
      if (mounted &&
          kIsWeb &&
          widget.embedInBottomBar &&
          MediaQuery.sizeOf(context).width >= _webCompactBreakpoint &&
          _activeWebThreadKey == key) {
        setState(() {});
      }
    } catch (_) {}

    _webMessageSubs[key] = service.onMessage.listen((msg) {
      if (!mounted) return;
      final myId = ProfileService().profile?.id.trim() ?? '';
      final isMine = myId.isNotEmpty && msg.senderId.trim() == myId;
      final list = _webThreadMessages.putIfAbsent(key, () => <WebChatMessageItem>[]);
      if (isMine) {
        final pendingIndex = list.indexWhere(
          (item) => item.isMe && item.isPending && item.text.trim() == msg.content.trim(),
        );
        if (pendingIndex >= 0) {
          list[pendingIndex] = list[pendingIndex].copyWith(
            isPending: false,
            isFailed: false,
            messageId: msg.messageId.trim().isEmpty ? null : msg.messageId.trim(),
            readAt: msg.readAt,
            deliveredAt: msg.deliveredAt,
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
              readAt: msg.readAt,
              deliveredAt: msg.deliveredAt,
            ),
          );
        }
      } else {
        list.add(
          WebChatMessageItem(
            text: msg.content,
            time: MaterialLocalizations.of(
              context,
            ).formatTimeOfDay(TimeOfDay.fromDateTime(msg.sentAt.toLocal())),
            isMe: false,
            messageId: msg.messageId.trim().isEmpty ? null : msg.messageId.trim(),
            readAt: msg.readAt,
            deliveredAt: msg.deliveredAt,
          ),
        );
      }
      final selectedPeer = (_selectedWebTargetUserId ?? '').trim();
      final viewingThisThread =
          selectedPeer.isNotEmpty && selectedPeer == targetUserId;
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
      // Always rebuild: Consumer depends on the static VM, but this State also
      // owns `_webThreadMessages`; a missed notify must not hide realtime text.
      if (mounted) {
        setState(() {});
      }
    });
    _webErrorSubs[key] = service.onError.listen((_) {});
    _webPresenceSubs[key] = service.onPresence.listen((ChatPresenceEvent e) {
      final peerId = (thread.targetUserId ?? '').trim();
      if (peerId.isEmpty) return;
      if (e.userId.trim() != peerId) return;
      ChatListScreenViewModel.applyPresenceForUser(
        subjectUserId: peerId,
        status: e.status,
        sentAt: e.sentAt,
      );
      if (mounted) setState(() {});
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
      if (mounted) setState(() {});
    });
    service.connect();
  }

  Future<void> _disposeWebThread(String key) async {
    await _webMessageSubs.remove(key)?.cancel();
    await _webErrorSubs.remove(key)?.cancel();
    await _webPresenceSubs.remove(key)?.cancel();
    await _webReceiptSubs.remove(key)?.cancel();
    _webThreadServices.remove(key)?.dispose();
  }

  bool _useEmbeddedListRealtimeLayout(BuildContext context) {
    if (!widget.embedInBottomBar) return false;
    return !kIsWeb || MediaQuery.sizeOf(context).width < _webCompactBreakpoint;
  }

  Future<void> _syncEmbeddedThreadRealtime(List<ChatThreadPreview> threads) async {
    final desiredKeys = <String>{};
    for (final t in threads) {
      final id = (t.targetUserId ?? '').trim();
      if (id.isEmpty) continue;
      desiredKeys.add(_threadKey(t));
    }

    final activeFullscreen =
        (ChatListRealtimeCoordinator.fullScreenDirectTargetUserId ?? '').trim();
    final activeFullscreenKey =
        activeFullscreen.isEmpty ? null : 'user:$activeFullscreen';

    final staleKeys = _webThreadServices.keys
        .where((k) => !desiredKeys.contains(k))
        .toList(growable: false);
    for (final k in staleKeys) {
      await _disposeWebThread(k);
    }

    for (final t in threads) {
      final id = (t.targetUserId ?? '').trim();
      if (id.isEmpty) continue;
      final key = _threadKey(t);
      if (activeFullscreenKey != null && key == activeFullscreenKey) {
        await _disposeWebThread(key);
        continue;
      }
      await _bindWebThread(t);
    }
  }

  Future<void> _openEmbeddedDirectChat(ChatThreadPreview t) async {
    final id = (t.targetUserId ?? '').trim();
    final args = ChatRouteArgs(
      contactName: t.userName,
      targetUserId: t.targetUserId,
      isOnline: t.isOnline,
      contactAvatarUrl: t.avatarUrl,
    );
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

  @override
  void initState() {
    super.initState();
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
  void dispose() {
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
    for (final service in _webThreadServices.values) {
      service.dispose();
    }
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
          if (widget.embedInBottomBar &&
              isActiveTab &&
              _useEmbeddedListRealtimeLayout(context)) {
            final ids = <String>{
              for (final t in model.threads) (t.targetUserId ?? '').trim(),
            }..remove('');
            final sig = ids.join('\u001f');
            if (sig != _lastEmbeddedRealtimeThreadIdsSig) {
              _lastEmbeddedRealtimeThreadIdsSig = sig;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!mounted) return;
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
                    }
                    _webMessageController.clear();
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
