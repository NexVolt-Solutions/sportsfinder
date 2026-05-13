import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/utils/date_time_formatters.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_list_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/webwidget/web_dashboard_widgets.dart';
import 'package:sport_finding/feature/widget/direct_chat_bubble.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

class WebChatMessageItem {
  const WebChatMessageItem({
    required this.text,
    required this.time,
    required this.isMe,
    this.isPending = false,
    this.isFailed = false,
    this.isDeleted = false,
    this.localId = '',
    this.messageId,
    this.readAt,
    this.deliveredAt,
  });

  final String text;
  final String time;
  final bool isMe;
  final bool isPending;
  final bool isFailed;
  final bool isDeleted;
  final String localId;
  final String? messageId;
  final DateTime? readAt;
  final DateTime? deliveredAt;

  WebChatMessageItem copyWith({
    String? text,
    String? time,
    bool? isMe,
    bool? isPending,
    bool? isFailed,
    bool? isDeleted,
    String? localId,
    String? messageId,
    DateTime? readAt,
    DateTime? deliveredAt,
  }) {
    return WebChatMessageItem(
      text: text ?? this.text,
      time: time ?? this.time,
      isMe: isMe ?? this.isMe,
      isPending: isPending ?? this.isPending,
      isFailed: isFailed ?? this.isFailed,
      isDeleted: isDeleted ?? this.isDeleted,
      localId: localId ?? this.localId,
      messageId: messageId ?? this.messageId,
      readAt: readAt ?? this.readAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}

class WebChatContent extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  WebChatContent({
    super.key,
    required this.model,
    required this.threads,
    required this.selectedThreadIndex,
    required this.messageController,
    required this.onThreadSelected,
    required this.onPickUser,
    required this.onSendMessage,
    required this.onClearChat,
    required this.onDeleteChat,
    required this.activeMessages,
    required this.showUnreadOnly,
    required this.onUnreadToggle,
    this.searchController,
    this.onSearchChanged,
    this.searchQuery = '',
    this.chatListSelectionMode = false,
    this.selectedThreadKeys = const <String>{},
    this.onExitChatListSelection,
    this.onDeleteSelectedThreads,
    this.onThreadSelectionTap,
    this.onThreadLongPressForSelection,
    this.onPeerProfileTap,
  });

  final ChatListScreenViewModel model;
  final List<ChatThreadPreview> threads;
  final int? selectedThreadIndex;
  final TextEditingController messageController;
  final ValueChanged<int?> onThreadSelected;
  final VoidCallback onPickUser;
  final VoidCallback onSendMessage;
  final VoidCallback onClearChat;
  final VoidCallback onDeleteChat;
  final List<WebChatMessageItem> activeMessages;
  final bool showUnreadOnly;
  final ValueChanged<bool> onUnreadToggle;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String searchQuery;
  final bool chatListSelectionMode;
  final Set<String> selectedThreadKeys;
  final VoidCallback? onExitChatListSelection;
  final VoidCallback? onDeleteSelectedThreads;
  final ValueChanged<int>? onThreadSelectionTap;
  final ValueChanged<int>? onThreadLongPressForSelection;
  final VoidCallback? onPeerProfileTap;

  @override
  State<WebChatContent> createState() => _WebChatContentState();
}

class _WebChatContentState extends State<WebChatContent> {
  final ScrollController _messagesScrollController = ScrollController();
  int _scrollJob = 0;

  String _rowKey(ChatThreadPreview t) {
    final targetUserId = (t.targetUserId ?? '').trim();
    if (targetUserId.isNotEmpty) return 'user:$targetUserId';
    return 'name:${t.userName.trim().toLowerCase()}';
  }

  /// Defers work until after layout; avoids crashes when the web engine view
  /// is torn down (e.g. hot restart) while a frame is still pending.
  void _whenFrameSafe(void Function() fn, {required int job}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || job != _scrollJob) return;
      if (!context.mounted) return;
      try {
        if (PlatformDispatcher.instance.views.isEmpty) return;
      } catch (_) {
        return;
      }
      try {
        fn();
      } catch (e, _) {
        debugPrint('[WebChat] post-frame work skipped: $e');
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    // Hot reload on web can reset scroll position; keep the chat pinned
    // to the visual bottom (newest message) like mobile/WhatsApp.
    final job = ++_scrollJob;
    _whenFrameSafe(() => _scrollToBottom(animated: false), job: job);
  }

  @override
  void dispose() {
    _scrollJob++;
    _messagesScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!mounted) return;
    if (!_messagesScrollController.hasClients) return;
    // We render the chat with `reverse: true`, so offset 0 == visual bottom.
    const targetOffset = 0.0;
    try {
      if (animated) {
        _messagesScrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      } else {
        _messagesScrollController.jumpTo(targetOffset);
      }
    } catch (e, _) {
      debugPrint('[WebChat] scroll skipped: $e');
    }
  }

  @override
  void didUpdateWidget(covariant WebChatContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    final threadChanged =
        oldWidget.selectedThreadIndex != widget.selectedThreadIndex;
    final messagesChanged =
        oldWidget.activeMessages.length != widget.activeMessages.length;

    if (threadChanged || messagesChanged) {
      final job = ++_scrollJob;
      _whenFrameSafe(() => _scrollToBottom(animated: false), job: job);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final threads = widget.threads;
    final selectedThreadIndex = widget.selectedThreadIndex;
    final messageController = widget.messageController;
    final onThreadSelected = widget.onThreadSelected;
    final onPickUser = widget.onPickUser;
    final onClearChat = widget.onClearChat;
    final onDeleteChat = widget.onDeleteChat;
    final activeMessages = widget.activeMessages;
    final showUnreadOnly = widget.showUnreadOnly;
    final onUnreadToggle = widget.onUnreadToggle;
    final searchController = widget.searchController;
    final onSearchChanged = widget.onSearchChanged;
    final searchQuery = widget.searchQuery;

    final hasThreads = threads.isNotEmpty;
    final normalizedQuery = searchQuery.trim();
    final isFiltering = normalizedQuery.isNotEmpty;
    final hasAnyThreads = model.hasThreads;
    final showNoMatches = isFiltering && hasAnyThreads && !hasThreads;
    final safeSelected =
        hasThreads &&
            selectedThreadIndex != null &&
            selectedThreadIndex >= 0 &&
            selectedThreadIndex < threads.length
        ? selectedThreadIndex
        : null;
    final activeThread = safeSelected == null ? null : threads[safeSelected];
    final at = activeThread;
    final canTapPeerProfile =
        at != null &&
        !widget.chatListSelectionMode &&
        (at.targetUserId ?? '').trim().isNotEmpty &&
        widget.onPeerProfileTap != null;

    debugPrint(
      '[WebChat] build thread=${activeThread?.targetUserId ?? '-'} '
      'selected=$selectedThreadIndex safe=$safeSelected '
      'msgs=${activeMessages.length} threads=${threads.length}',
    );

    return MainFrame(
      showDecorationLayer: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final messageMaxWidth = (constraints.maxWidth * 0.52).clamp(
            280.0,
            520.0,
          );
          return Padding(
            padding: context.padSym(h: 20, v: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WebDashboardTitle(
                  title: 'Chat',
                  subtitle: 'Start messaging now',
                ),
                SizedBox(height: context.h(16)),
                if (widget.chatListSelectionMode)
                  Padding(
                    padding: EdgeInsets.only(bottom: context.h(8)),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Cancel',
                          icon: const Icon(Icons.close),
                          onPressed: widget.onExitChatListSelection,
                        ),
                        Expanded(
                          child: Text(
                            '${widget.selectedThreadKeys.length} selected',
                            style: context.appText.text16W500.copyWith(
                              color: context.appColors.greyDark,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: widget.selectedThreadKeys.isEmpty
                              ? null
                              : widget.onDeleteSelectedThreads,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  // Always keep the two-pane layout, even when empty,
                  // so the UI stays consistent with the web design.
                  child: Row(
                    children: [
                      Expanded(
                        flex: 10,
                        child: Column(
                          children: [
                            Column(
                              children: [
                                SearchBarWidget(
                                  isShow: false,
                                  controller: searchController,
                                  // Search only filters the user list (threads).
                                  hintText: 'Start a new chat now...',
                                  onChanged: onSearchChanged,
                                ),
                                SizedBox(height: context.h(10)),

                                if (!showNoMatches &&
                                    !widget.chatListSelectionMode)
                                  Row(
                                    children: [
                                      WebFilterChip(
                                        label: 'All',
                                        selected: !showUnreadOnly,
                                        onTap: () => onUnreadToggle(false),
                                      ),
                                      SizedBox(width: context.w(6)),
                                      WebFilterChip(
                                        label: 'Unread',
                                        selected: showUnreadOnly,
                                        onTap: () => onUnreadToggle(true),
                                      ),
                                      SizedBox(width: context.w(6)),
                                    ],
                                  ),
                              ],
                            ),
                            SizedBox(height: context.h(10)),
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    padding: context.padSym(h: 12, v: 12),
                                    decoration: BoxDecoration(
                                      color: context.appColors.blue10,
                                      borderRadius: BorderRadius.circular(
                                        context.radius(12),
                                      ),
                                      border: Border.all(
                                        color: context.appColors.greylight
                                            .withValues(alpha: 0.45),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: context.appColors.greyDark
                                              .withValues(alpha: 0.06),
                                          blurRadius: 18,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: showNoMatches
                                        ? Center(
                                            child: Text(
                                              'No data found',
                                              style: context.appText.text14W400
                                                  .copyWith(
                                                    color: context
                                                        .appColors
                                                        .greylight,
                                                  ),
                                            ),
                                          )
                                        : (threads.isEmpty
                                              ? Center(
                                                  child: Text(
                                                    'No chats yet',
                                                    style: context
                                                        .appText
                                                        .text14W400
                                                        .copyWith(
                                                          color: context
                                                              .appColors
                                                              .greylight,
                                                        ),
                                                  ),
                                                )
                                              : ListView.separated(
                                                  itemCount: threads.length,
                                                  separatorBuilder: (_, _) =>
                                                      SizedBox(
                                                        height: context.h(8),
                                                      ),
                                                  itemBuilder: (context, index) {
                                                    final thread =
                                                        threads[index];
                                                    final isOpenSelected =
                                                        index == safeSelected;
                                                    final multi = widget
                                                        .chatListSelectionMode;
                                                    final rowKey = _rowKey(
                                                      thread,
                                                    );
                                                    final checked =
                                                        multi &&
                                                        widget
                                                            .selectedThreadKeys
                                                            .contains(rowKey);
                                                    final textAsSelected =
                                                        checked ||
                                                        (isOpenSelected &&
                                                            !multi);
                                                    final highlightOpen =
                                                        isOpenSelected &&
                                                        !multi;
                                                    return InkWell(
                                                      onLongPress:
                                                          widget.onThreadLongPressForSelection ==
                                                              null
                                                          ? null
                                                          : () => widget
                                                                .onThreadLongPressForSelection!
                                                                .call(index),
                                                      onTap: () {
                                                        if (multi) {
                                                          widget
                                                              .onThreadSelectionTap
                                                              ?.call(index);
                                                        } else {
                                                          onThreadSelected(
                                                            index,
                                                          );
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: context.padSym(
                                                          h: 10,
                                                          v: 10,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: checked
                                                              ? context
                                                                    .appColors
                                                                    .primary
                                                                    .withValues(
                                                                      alpha:
                                                                          0.10,
                                                                    )
                                                              : highlightOpen
                                                              ? context
                                                                    .appColors
                                                                    .blue10
                                                              : context
                                                                    .appColors
                                                                    .white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                context.radius(
                                                                  12,
                                                                ),
                                                              ),
                                                          border:
                                                              checked ||
                                                                  highlightOpen
                                                              ? Border.all(
                                                                  color: context
                                                                      .appColors
                                                                      .primary
                                                                      .withValues(
                                                                        alpha:
                                                                            0.35,
                                                                      ),
                                                                  width: 1,
                                                                )
                                                              : null,
                                                          boxShadow:
                                                              highlightOpen
                                                              ? [
                                                                  BoxShadow(
                                                                    color: context
                                                                        .appColors
                                                                        .primary
                                                                        .withValues(
                                                                          alpha:
                                                                              0.08,
                                                                        ),
                                                                    blurRadius:
                                                                        18,
                                                                    offset:
                                                                        const Offset(
                                                                          0,
                                                                          10,
                                                                        ),
                                                                  ),
                                                                ]
                                                              : null,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            if (multi) ...[
                                                              Checkbox(
                                                                value: checked,
                                                                onChanged:
                                                                    (
                                                                      _,
                                                                    ) => widget
                                                                        .onThreadSelectionTap
                                                                        ?.call(
                                                                          index,
                                                                        ),
                                                              ),
                                                              SizedBox(
                                                                width: context
                                                                    .w(4),
                                                              ),
                                                            ],
                                                            Stack(
                                                              clipBehavior:
                                                                  Clip.none,
                                                              children: [
                                                                AppAvatar(
                                                                  size: context
                                                                      .w(34),
                                                                  fallbackText:
                                                                      thread
                                                                          .userName,
                                                                  imageUrl:
                                                                      (thread.avatarUrl ??
                                                                              '')
                                                                          .trim()
                                                                          .isEmpty
                                                                      ? null
                                                                      : thread
                                                                            .avatarUrl!
                                                                            .trim(),
                                                                  backgroundColor:
                                                                      context
                                                                          .appColors
                                                                          .white,
                                                                  iconColor: context
                                                                      .appColors
                                                                      .primary,
                                                                ),
                                                                if (thread
                                                                    .isOnline)
                                                                  Positioned(
                                                                    right: 0,
                                                                    bottom: 0,
                                                                    child: Container(
                                                                      width: context
                                                                          .w(
                                                                            10,
                                                                          ),
                                                                      height:
                                                                          context.w(
                                                                            10,
                                                                          ),
                                                                      decoration: BoxDecoration(
                                                                        color: const Color(
                                                                          0xFF25D366,
                                                                        ),
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        border: Border.all(
                                                                          color:
                                                                              context.appColors.white ??
                                                                              Colors.white,
                                                                          width:
                                                                              1.5,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              width: context.w(
                                                                10,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    thread
                                                                        .userName,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: context
                                                                        .appText
                                                                        .text14W500
                                                                        .copyWith(
                                                                          color:
                                                                              textAsSelected
                                                                              ? context.appColors.primary
                                                                              : context.appColors.greyDark,
                                                                        ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        context
                                                                            .h(
                                                                              2,
                                                                            ),
                                                                  ),
                                                                  Text(
                                                                    thread
                                                                        .lastMessage,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: context
                                                                        .appText
                                                                        .text12W400
                                                                        .copyWith(
                                                                          color:
                                                                              textAsSelected
                                                                              ? context.appColors.primary.withValues(
                                                                                  alpha: 0.72,
                                                                                )
                                                                              : context.appColors.greyDark,
                                                                        ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        context
                                                                            .h(
                                                                              2,
                                                                            ),
                                                                  ),
                                                                  Text(
                                                                    () {
                                                                      if (thread
                                                                          .isOnline) {
                                                                        return 'Online';
                                                                      }
                                                                      final iso =
                                                                          (thread.lastSeenIso ??
                                                                                  '')
                                                                              .trim();
                                                                      if (iso
                                                                          .isEmpty) {
                                                                        return 'Offline';
                                                                      }
                                                                      final parsed =
                                                                          DateTime.tryParse(
                                                                            iso,
                                                                          );
                                                                      if (parsed ==
                                                                          null) {
                                                                        return 'Offline';
                                                                      }
                                                                      return 'Last seen ${DateTimeFormatters.relativeLabel(parsed.toLocal())}';
                                                                    }(),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: context
                                                                        .appText
                                                                        .text12W400
                                                                        .copyWith(
                                                                          fontSize: context.text(
                                                                            10,
                                                                          ),
                                                                          color: context
                                                                              .appColors
                                                                              .greylight,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: context.w(
                                                                6,
                                                              ),
                                                            ),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  thread
                                                                      .lastTime,
                                                                  style: context
                                                                      .appText
                                                                      .text12W400
                                                                      .copyWith(
                                                                        color: context
                                                                            .appColors
                                                                            .greylight,
                                                                      ),
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      context.h(
                                                                        6,
                                                                      ),
                                                                ),
                                                                if (thread
                                                                        .unreadCount >
                                                                    0)
                                                                  Container(
                                                                    padding: context
                                                                        .padSym(
                                                                          h: 8,
                                                                          v: 3,
                                                                        ),
                                                                    decoration: BoxDecoration(
                                                                      color: context
                                                                          .appColors
                                                                          .primary,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            999,
                                                                          ),
                                                                    ),
                                                                    child: Text(
                                                                      thread.unreadCount >
                                                                              99
                                                                          ? '99+'
                                                                          : '${thread.unreadCount}',
                                                                      style: context
                                                                          .appText
                                                                          .text12W500
                                                                          .copyWith(
                                                                            color:
                                                                                context.appColors.onPrimary,
                                                                          ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )),
                                  ),
                                  if (!widget.chatListSelectionMode)
                                    Positioned(
                                      right: context.w(40),
                                      bottom: context.h(40),
                                      child: InkWell(
                                        onTap: onPickUser,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        child: Container(
                                          width: context.w(54),
                                          height: context.w(54),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              context.radius(12),
                                            ),
                                            color: context.appColors.primary,
                                            boxShadow: [
                                              BoxShadow(
                                                color: context.appColors.primary
                                                    .withValues(alpha: 0.22),
                                                blurRadius: 18,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.add_rounded,
                                            color: context.appColors.onPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: context.w(12)),
                      Expanded(
                        flex: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: context.appColors.primary,
                              width: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(
                              context.radius(12),
                            ),
                          ),
                          child: Column(
                            children: [
                              /// 🔹 HEADER
                              Container(
                                padding: context.padSym(h: 14, v: 10),
                                decoration: BoxDecoration(
                                  color: context.appColors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                      context.radius(12),
                                    ),
                                    topRight: Radius.circular(
                                      context.radius(12),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: canTapPeerProfile
                                            ? () => widget.onPeerProfileTap!()
                                            : null,
                                        child: Row(
                                          children: [
                                            AppAvatar(
                                              size: context.w(36),
                                              imageUrl: normalizeImageUrl(
                                                activeThread?.avatarUrl,
                                              ),
                                              fallbackText:
                                                  activeThread?.userName,
                                              backgroundColor:
                                                  context.appColors.blue10,
                                              iconColor:
                                                  context.appColors.primary,
                                            ),
                                            SizedBox(width: context.w(10)),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    activeThread?.userName ??
                                                        '',
                                                    style: context
                                                        .appText
                                                        .text14W500,
                                                  ),
                                                  if (activeThread != null) ...[
                                                    SizedBox(
                                                      height: context.h(2),
                                                    ),
                                                    Text(
                                                      () {
                                                        if (activeThread
                                                            .isOnline) {
                                                          return 'Online';
                                                        }
                                                        final iso =
                                                            (activeThread
                                                                        .lastSeenIso ??
                                                                    '')
                                                                .trim();
                                                        if (iso.isEmpty) {
                                                          return 'Offline';
                                                        }
                                                        final parsed =
                                                            DateTime.tryParse(
                                                              iso,
                                                            );
                                                        if (parsed == null) {
                                                          return 'Offline';
                                                        }
                                                        return 'Last seen ${DateTimeFormatters.relativeLabel(parsed.toLocal())}';
                                                      }(),
                                                      style: context
                                                          .appText
                                                          .text12W400
                                                          .copyWith(
                                                            color: context
                                                                .appColors
                                                                .greylight,
                                                          ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (activeThread != null)
                                      PopupMenuButton<String>(
                                        color: context.appColors.white,
                                        icon: Icon(
                                          Icons.more_horiz_rounded,
                                          color: context.appColors.greyDark,
                                        ),
                                        onSelected: (value) {
                                          if (value == 'clear') {
                                            onClearChat();
                                            return;
                                          }
                                          onDeleteChat();
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'clear',
                                            child: Text(
                                              'Clear Chat',
                                              style: context.appText.text12W400
                                                  .copyWith(
                                                    color: context
                                                        .appColors
                                                        .primary,
                                                  ),
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text(
                                              'Delete Chat',
                                              style: context.appText.text12W400
                                                  .copyWith(
                                                    color:
                                                        context.appColors.error,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),

                              /// 🔹 CHAT BODY + INPUT
                              Expanded(
                                child: Container(
                                  padding: context.padSym(h: 12, v: 12),
                                  decoration: BoxDecoration(
                                    color: context.appColors.blue10,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(
                                        context.radius(12),
                                      ),
                                      bottomRight: Radius.circular(
                                        context.radius(12),
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      /// 🟢 MESSAGES
                                      Expanded(
                                        child: activeThread == null
                                            ? Center(
                                                child: Text(
                                                  'Select a chat to start messaging.',
                                                  style: context
                                                      .appText
                                                      .text14W400
                                                      .copyWith(
                                                        color: context
                                                            .appColors
                                                            .greylight,
                                                      ),
                                                ),
                                              )
                                            : ListView.builder(
                                                key: ValueKey(
                                                  activeThread.targetUserId,
                                                ),
                                                controller:
                                                    _messagesScrollController,
                                                reverse: true,
                                                itemCount:
                                                    activeMessages.length,
                                                itemBuilder: (context, i) {
                                                  final message =
                                                      activeMessages[activeMessages
                                                              .length -
                                                          1 -
                                                          i];
                                                  if (message.isDeleted &&
                                                      message.isMe) {
                                                    return const SizedBox.shrink();
                                                  }
                                                  return Align(
                                                    alignment: message.isMe
                                                        ? Alignment.centerRight
                                                        : Alignment.centerLeft,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                        bottom: context.h(8),
                                                      ),
                                                      child: DirectChatBubble(
                                                        maxWidth:
                                                            messageMaxWidth,
                                                        model:
                                                            DirectChatBubbleModel.plainText(
                                                              text:
                                                                  message.text,
                                                              time:
                                                                  message.time,
                                                              isMe:
                                                                  message.isMe,
                                                              isPending: message
                                                                  .isPending,
                                                              isFailed: message
                                                                  .isFailed,
                                                              isDeleted: message
                                                                  .isDeleted,
                                                              readAt: message
                                                                  .readAt,
                                                              deliveredAt: message
                                                                  .deliveredAt,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                      ),

                                      /// 🟢 INPUT
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: context.h(20),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextFormFieldWidget(
                                                controller: messageController,
                                                hintText:
                                                    'Type your message...',
                                                textInputAction:
                                                    TextInputAction.send,
                                                onFieldSubmitted: (_) {
                                                  if (activeThread == null) {
                                                    return;
                                                  }
                                                  if (messageController.text
                                                      .trim()
                                                      .isEmpty) {
                                                    return;
                                                  }
                                                  debugPrint(
                                                    '[WebChat] submit-send target=${activeThread.targetUserId} '
                                                    'len=${messageController.text.trim().length}',
                                                  );
                                                  widget.onSendMessage();
                                                  final job = ++_scrollJob;
                                                  _whenFrameSafe(
                                                    () => _scrollToBottom(
                                                      animated: true,
                                                    ),
                                                    job: job,
                                                  );
                                                },
                                                onChanged: (_) {
                                                  final job = ++_scrollJob;
                                                  _whenFrameSafe(
                                                    () => _scrollToBottom(
                                                      animated: false,
                                                    ),
                                                    job: job,
                                                  );
                                                },
                                                onTap: () {
                                                  final job = ++_scrollJob;
                                                  _whenFrameSafe(
                                                    () => _scrollToBottom(
                                                      animated: false,
                                                    ),
                                                    job: job,
                                                  );
                                                },
                                              ),
                                            ),
                                            SizedBox(width: context.w(12)),
                                            IconButton(
                                              onPressed: activeThread == null
                                                  ? null
                                                  : () {
                                                      debugPrint(
                                                        '[WebChat] click-send target=${activeThread.targetUserId} '
                                                        'len=${messageController.text.trim().length}',
                                                      );
                                                      widget.onSendMessage();
                                                      final job = ++_scrollJob;
                                                      _whenFrameSafe(
                                                        () => _scrollToBottom(
                                                          animated: true,
                                                        ),
                                                        job: job,
                                                      );
                                                    },
                                              icon: Icon(
                                                Icons.send_rounded,
                                                size: context.w(24),
                                                color: activeThread == null
                                                    ? context
                                                          .appColors
                                                          .greylight
                                                    : context.appColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class WebFilterChip extends StatelessWidget {
  const WebFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.radius(12)),
      child: Container(
        padding: context.padSym(h: 21, v: 4),
        decoration: BoxDecoration(
          color: selected ? c.primary : c.white,
          borderRadius: BorderRadius.circular(context.radius(12)),
          border: Border.all(
            color: selected ? c.primary : c.greylight.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: context.appText.text12W400.copyWith(
            color: selected ? c.onPrimary : c.greyDark,
          ),
        ),
      ),
    );
  }
}
