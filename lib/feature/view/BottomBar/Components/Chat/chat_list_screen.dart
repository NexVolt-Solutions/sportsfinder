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
  int? _selectedWebThreadIndex;
  bool _webUnreadOnly = false;
  final Map<String, List<WebChatMessageItem>> _webThreadMessages =
      <String, List<WebChatMessageItem>>{};
  final Map<String, MatchChatService> _webThreadServices =
      <String, MatchChatService>{};
  final Map<String, StreamSubscription<RealtimeChatMessage>> _webMessageSubs =
      <String, StreamSubscription<RealtimeChatMessage>>{};
  final Map<String, StreamSubscription<String>> _webErrorSubs =
      <String, StreamSubscription<String>>{};
  String? _activeWebThreadKey;
  int _webLocalMessageCounter = 0;
  bool _wasActiveBottomBarTab = false;

  String _threadKey(ChatThreadPreview thread) {
    final targetUserId = (thread.targetUserId ?? '').trim();
    if (targetUserId.isNotEmpty) return 'user:$targetUserId';
    return 'name:${thread.userName.trim().toLowerCase()}';
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

    _safeVm.startOrOpenThread(selectedName, targetUserId: selectedTargetUserId);
    _webThreadMessages.putIfAbsent(
      'user:$selectedTargetUserId',
      () => <WebChatMessageItem>[],
    );
    if (kIsWeb && widget.embedInBottomBar) {
      setState(() => _selectedWebThreadIndex = 0);
      await _bindSelectedWebThread();
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
    final selectedIndex = _selectedWebThreadIndex;
    if (selectedIndex == null) return;
    if (selectedIndex < 0 || selectedIndex >= _safeVm.threads.length) return;
    await _bindWebThread(_safeVm.threads[selectedIndex]);
  }

  Future<void> _bindWebThread(ChatThreadPreview thread) async {
    final targetUserId = (thread.targetUserId ?? '').trim();
    if (targetUserId.isEmpty) return;
    final key = _threadKey(thread);
    _activeWebThreadKey = key;

    if (_webThreadServices.containsKey(key)) return;

    final token = await AppPreferences.getAccessToken();
    if (token == null || token.isEmpty) return;

    final service = MatchChatService(accessToken: token, targetUserId: targetUserId);
    _webThreadServices[key] = service;

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
            ),
          );
        }
      }
      if (mounted && _activeWebThreadKey == key) {
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
          ),
        );
      }
      if (!isMine && _activeWebThreadKey != key) {
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
          // keep unread as-is (or 0 for active thread)
          unreadCount: _activeWebThreadKey == key ? 0 : null,
        );
      }
      if (mounted && _activeWebThreadKey == key) {
        setState(() {});
      }
    });
    _webErrorSubs[key] = service.onError.listen((_) {});
    service.connect();
  }

  Future<void> _disposeWebThread(String key) async {
    await _webMessageSubs.remove(key)?.cancel();
    await _webErrorSubs.remove(key)?.cancel();
    _webThreadServices.remove(key)?.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeVm.refreshDirectChats();
    });
  }

  @override
  void dispose() {
    _webMessageController.dispose();
    _searchController.dispose();
    for (final sub in _webMessageSubs.values) {
      sub.cancel();
    }
    for (final sub in _webErrorSubs.values) {
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
                                          Navigator.pushNamed(
                                            context,
                                            RoutesName.chatScreen,
                                            arguments: ChatRouteArgs(
                                              contactName: t.userName,
                                              targetUserId: t.targetUserId,
                                              isOnline: t.isOnline,
                                            ),
                                          );
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
                                                backgroundColor:
                                                    context.appColors.greylight,
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
                                                style: context.appText.text12W500
                                                    .copyWith(
                                                  color: context
                                                      .appColors.greylight,
                                                ),
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
        if (_selectedWebThreadIndex != null) {
          setState(() => _selectedWebThreadIndex = null);
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
          final query = _searchController.text.trim().toLowerCase();
          final allThreads = model.threads;
          final List<int> indexMap = <int>[];
          final List<ChatThreadPreview> filteredThreads = <ChatThreadPreview>[];
          for (var i = 0; i < allThreads.length; i++) {
            final t = allThreads[i];
            if (_webUnreadOnly && t.unreadCount <= 0) continue;
            if (query.isEmpty) {
              indexMap.add(i);
              filteredThreads.add(t);
              continue;
            }
            final haystack =
                '${t.userName} ${t.lastMessage}'.toLowerCase();
            if (haystack.contains(query)) {
              indexMap.add(i);
              filteredThreads.add(t);
            }
          }

          final filteredSelectedIndex = _selectedWebThreadIndex == null
              ? null
              : indexMap.indexOf(_selectedWebThreadIndex!);

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
                      (filteredSelectedIndex != null && filteredSelectedIndex >= 0)
                          ? filteredSelectedIndex
                          : null,
                  activeMessages:
                      (_selectedWebThreadIndex != null &&
                              _selectedWebThreadIndex! >= 0 &&
                              _selectedWebThreadIndex! < allThreads.length)
                          ? List<WebChatMessageItem>.unmodifiable(
                              _webThreadMessages[_threadKey(
                                    allThreads[_selectedWebThreadIndex!],
                                  )] ??
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
                    final mapped =
                        (index != null && index >= 0 && index < indexMap.length)
                            ? indexMap[index]
                            : null;
                    setState(() => _selectedWebThreadIndex = mapped);
                    if (mapped != null) {
                      final t = model.threads[mapped];
                      ChatListScreenViewModel.markRead(
                        userName: t.userName,
                        targetUserId: t.targetUserId,
                      );
                    }
                    _bindSelectedWebThread();
                  },
                  onPickUser: _pickAndOpenUser,
                  onClearChat: () {
                    _webMessageController.clear();
                    setState(() => _selectedWebThreadIndex = null);
                  },
                  onDeleteChat: () {
                    final selectedIndex = _selectedWebThreadIndex;
                    if (selectedIndex == null ||
                        selectedIndex < 0 ||
                        selectedIndex >= model.threads.length) {
                      return;
                    }
                    final thread = model.threads[selectedIndex];
                    _webThreadMessages.remove(_threadKey(thread));
                    _disposeWebThread(_threadKey(thread));
                    ChatListScreenViewModel.removeThread(
                      targetUserId: thread.targetUserId,
                      userName: thread.userName,
                    );
                    _webMessageController.clear();
                    setState(() => _selectedWebThreadIndex = null);
                  },
                  onSendMessage: () {
                    final selectedIndex = _selectedWebThreadIndex;
                    if (!model.hasThreads ||
                        selectedIndex == null ||
                        selectedIndex < 0 ||
                        selectedIndex >= model.threads.length) {
                      return;
                    }
                    final activeThread = model.threads[selectedIndex];
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
                                              Navigator.pushNamed(
                                                context,
                                                RoutesName.chatScreen,
                                                arguments: ChatRouteArgs(
                                                  contactName: t.userName,
                                                  targetUserId: t.targetUserId,
                                                  isOnline: t.isOnline,
                                                ),
                                              );
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
            // BottomBarScreen owns the Scaffold (and FAB).
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
