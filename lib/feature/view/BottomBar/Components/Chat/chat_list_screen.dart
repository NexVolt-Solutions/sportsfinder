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
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_list_screen_view_model.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Chat/web/web_chat_content.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key, this.embedInBottomBar = false});

  /// When true, [BottomBarScreen] supplies the shared [AppBarWidget].
  final bool embedInBottomBar;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  ChatListScreenViewModel? _vm;
  ChatListScreenViewModel get _safeVm => _vm ??= ChatListScreenViewModel();
  final TextEditingController _webMessageController = TextEditingController();
  int? _selectedWebThreadIndex;
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
      ChatListScreenViewModel.upsertThread(
        userName: thread.userName,
        targetUserId: thread.targetUserId,
        lastMessage: msg.content,
        lastAt: msg.sentAt,
      );
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
  void dispose() {
    _webMessageController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _safeVm,
      child: Consumer<ChatListScreenViewModel>(
        builder: (context, model, _) {
          if (kIsWeb && widget.embedInBottomBar) {
            return WebChatContent(
              model: model,
              selectedThreadIndex: _selectedWebThreadIndex,
              activeMessages:
                  (_selectedWebThreadIndex != null &&
                      _selectedWebThreadIndex! >= 0 &&
                      _selectedWebThreadIndex! < model.threads.length)
                  ? List<WebChatMessageItem>.unmodifiable(
                      _webThreadMessages[_threadKey(
                            model.threads[_selectedWebThreadIndex!],
                          )] ??
                          const <WebChatMessageItem>[],
                    )
                  : const <WebChatMessageItem>[],
              messageController: _webMessageController,
              onThreadSelected: (index) {
                setState(() => _selectedWebThreadIndex = index);
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
                final localId = 'web_local_${_webLocalMessageCounter}_${now.microsecondsSinceEpoch}';
                list.add(
                  WebChatMessageItem(
                    text: text,
                    time:
                        MaterialLocalizations.of(
                          context,
                        ).formatTimeOfDay(TimeOfDay.fromDateTime(now)),
                    isMe: true,
                    isPending: true,
                    localId: localId,
                  ),
                );
                final sent = _webThreadServices[key]?.sendMessage(text) ?? false;
                if (!sent) {
                  final index = list.indexWhere((item) => item.localId == localId);
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
          }
          return Scaffold(
            backgroundColor: widget.embedInBottomBar
                ? Colors.transparent
                : null,
            floatingActionButton: FloatingActionButton(
              onPressed: _pickAndOpenUser,
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.add, color: Colors.white),
            ),
            body: MainFrame(
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
                    child: model.hasThreads
                        ? ListView.separated(
                            padding: context.padSym(h: 20, v: 8),
                            itemCount: model.threads.length,
                            separatorBuilder: (_, _) =>
                                SizedBox(height: context.h(10)),
                            itemBuilder: (context, index) {
                              final t = model.threads[index];
                              return GestureDetector(
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
                                  padding: context.padSym(h: 12, v: 10),
                                  decoration: BoxDecoration(
                                    color: context.appColors.blue10,
                                    borderRadius: BorderRadius.circular(
                                      context.radius(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: context.radius(22),
                                        backgroundColor:
                                            context.appColors.greylight,
                                        child: Text(
                                          t.userName.isNotEmpty
                                              ? t.userName[0].toUpperCase()
                                              : 'U',
                                        ),
                                      ),
                                      SizedBox(width: context.w(12)),
                                      Expanded(
                                        child: NormalText(
                                          titleText: t.userName,
                                          subText: t.lastMessage,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: context.w(8)),
                                      Text(
                                        t.lastTime,
                                        style: context.appText.text12W500
                                            .copyWith(
                                              color:
                                                  context.appColors.greylight,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
            ),
          );
        },
      ),
    );
  }
}
