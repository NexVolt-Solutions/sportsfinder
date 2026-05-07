import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_list_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/webwidget/web_dashboard_widgets.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';

class WebChatMessageItem {
  const WebChatMessageItem({
    required this.text,
    required this.time,
    required this.isMe,
    this.isPending = false,
    this.isFailed = false,
    this.localId = '',
  });

  final String text;
  final String time;
  final bool isMe;
  final bool isPending;
  final bool isFailed;
  final String localId;

  WebChatMessageItem copyWith({
    String? text,
    String? time,
    bool? isMe,
    bool? isPending,
    bool? isFailed,
    String? localId,
  }) {
    return WebChatMessageItem(
      text: text ?? this.text,
      time: time ?? this.time,
      isMe: isMe ?? this.isMe,
      isPending: isPending ?? this.isPending,
      isFailed: isFailed ?? this.isFailed,
      localId: localId ?? this.localId,
    );
  }
}

class WebChatContent extends StatelessWidget {
  const WebChatContent({
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
    this.searchController,
    this.onSearchChanged,
    this.searchQuery = '',
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
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final hasThreads = threads.isNotEmpty;
    final normalizedQuery = searchQuery.trim();
    final isFiltering = normalizedQuery.isNotEmpty;
    final hasAnyThreads = model.hasThreads;
    final showNoMatches = isFiltering && hasAnyThreads && !hasThreads;
    final safeSelected =
        hasThreads &&
            selectedThreadIndex != null &&
            selectedThreadIndex! >= 0 &&
            selectedThreadIndex! < threads.length
        ? selectedThreadIndex
        : null;
    final activeThread = safeSelected == null
        ? null
        : threads[safeSelected];

    return MainFrame(
      showDecorationLayer: false,
      child: Padding(
        padding: context.padSym(h: 20, v: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WebDashboardTitle(
              title: 'Chat',
              subtitle: 'Start messaging now',
            ),
            SizedBox(height: context.h(16)),
            Expanded(
              child: (hasThreads || showNoMatches)
                  ? Row(
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
                                    hintText: 'Search chats...',
                                    onChanged: onSearchChanged,
                                  ),
                                  SizedBox(height: context.h(10)),

                                  if (!showNoMatches)
                                    Row(
                                      children: [
                                        const WebFilterChip(
                                          label: 'All',
                                          selected: true,
                                        ),
                                        SizedBox(width: context.w(6)),
                                        const WebFilterChip(label: 'Unread'),
                                        SizedBox(width: context.w(6)),
                                      ],
                                    ),
                                ],
                              ),
                              SizedBox(height: context.h(10)),
                              Expanded(
                                child: Container(
                                  padding: context.padSym(h: 12, v: 12),
                                  decoration: BoxDecoration(
                                    color: context.appColors.blue10,
                                    borderRadius: BorderRadius.circular(
                                      context.radius(12),
                                    ),
                                    border: Border.all(
                                      color: context.appColors.primary,

                                      width: 0.1,
                                    ),
                                  ),
                                  child: showNoMatches
                                      ? Center(
                                          child: Text(
                                            'No data found',
                                            style: context.appText.text14W400
                                                .copyWith(
                                              color: context.appColors.greylight,
                                            ),
                                          ),
                                        )
                                      : ListView.separated(
                                          itemCount: threads.length,
                                          separatorBuilder: (_, _) =>
                                              SizedBox(height: context.h(8)),
                                          itemBuilder: (context, index) {
                                            final thread = threads[index];
                                            final isSelected =
                                                index == safeSelected;
                                            return InkWell(
                                              onTap: () =>
                                                  onThreadSelected(index),
                                              child: Container(
                                                padding: context.padSym(
                                                  h: 10,
                                                  v: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? context.appColors.white
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    context.radius(12),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    AppAvatar(
                                                      size: context.w(34),
                                                      fallbackText:
                                                          thread.userName,
                                                      imageUrl: (thread.avatarUrl ??
                                                                  '')
                                                              .trim()
                                                              .isEmpty
                                                          ? null
                                                          : thread.avatarUrl!
                                                              .trim(),
                                                      backgroundColor: context
                                                          .appColors.white,
                                                      iconColor: context
                                                          .appColors.primary,
                                                    ),
                                                    SizedBox(
                                                      width: context.w(10),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            thread.userName,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: context
                                                                .appText
                                                                .text14W500,
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                context.h(2),
                                                          ),
                                                          Text(
                                                            thread.lastMessage,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: context
                                                                .appText
                                                                .text12W400
                                                                .copyWith(
                                                                  color: context
                                                                      .appColors
                                                                      .greyDark,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: context.w(6),
                                                    ),
                                                    Text(
                                                      thread.lastTime,
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
                                                ),
                                              ),
                                            );
                                          },
                                        ),
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
                                      AppAvatar(
                                        size: context.w(36),
                                        fallbackText: activeThread?.userName,
                                        backgroundColor:
                                            context.appColors.blue10,
                                        iconColor: context.appColors.primary,
                                      ),
                                      SizedBox(width: context.w(10)),
                                      Expanded(
                                        child: Text(
                                          activeThread?.userName ?? '',
                                          style: context.appText.text14W500,
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
                                                style: context
                                                    .appText
                                                    .text12W400
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
                                                style: context
                                                    .appText
                                                    .text12W400
                                                    .copyWith(
                                                      color: context
                                                          .appColors
                                                          .error,
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
                                              : ListView(
                                                  children: activeMessages
                                                      .map(
                                                        (message) => Align(
                                                          alignment: message.isMe
                                                              ? Alignment
                                                                    .centerRight
                                                              : Alignment
                                                                    .centerLeft,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                  bottom:
                                                                      context.h(
                                                                        8,
                                                                      ),
                                                                ),
                                                            child: WebBubble(
                                                              text:
                                                                  message.text,
                                                              time:
                                                                  message.time,
                                                              isMe:
                                                                  message.isMe,
                                                              isPending: message
                                                                  .isPending,
                                                              isFailed:
                                                                  message.isFailed,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
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
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        context.appColors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          context.radius(12),
                                                        ),
                                                    border: Border.all(
                                                      color: context
                                                          .appColors
                                                          .primary,
                                                    ),
                                                  ),
                                                  child: TextField(
                                                    controller:
                                                        messageController,
                                                    enabled:
                                                        activeThread != null,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Type your message...',
                                                      border: InputBorder.none,
                                                      contentPadding: context
                                                          .padSym(h: 12, v: 12),

                                                      suffixIcon:
                                                          activeThread == null
                                                          ? null
                                                          : GestureDetector(
                                                              onTap:
                                                                  onSendMessage,
                                                              child: Container(
                                                                padding: context
                                                                    .padSym(
                                                                      h: 8,
                                                                      v: 8,
                                                                    ),
                                                                child: SvgPicture.asset(
                                                                  AppAssets
                                                                      .chatSendIcon,
                                                                  colorFilter: ColorFilter.mode(
                                                                    context
                                                                        .appColors
                                                                        .primary,
                                                                    BlendMode
                                                                        .srcIn,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: SizedBox(
                        width: context.w(420),
                        child: WebDashboardPanel(
                          padding: context.padAll(32),
                          backgroundColor: context.appColors.blue10,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: context.w(52),
                                color: context.appColors.primary,
                              ),
                              SizedBox(height: context.h(16)),
                              Text(
                                'No chats yet',
                                style: context.appText.text18W400.copyWith(
                                  color: context.appColors.onSurface,
                                ),
                              ),
                              SizedBox(height: context.h(8)),
                              Text(
                                'Start a new conversation to see your chat screen here.',
                                textAlign: TextAlign.center,
                                style: context.appText.text14W400.copyWith(
                                  color: context.appColors.greylight,
                                ),
                              ),
                              SizedBox(height: context.h(20)),
                              _NewChatButton(onTap: onPickUser),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewChatButton extends StatelessWidget {
  const _NewChatButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.radius(12)),
      child: Container(
        width: context.w(44),
        height: context.w(44),
        decoration: BoxDecoration(
          color: context.appColors.primary,
          borderRadius: BorderRadius.circular(context.radius(12)),
        ),
        child: Icon(Icons.add, color: context.appColors.onPrimary),
      ),
    );
  }
}

class WebFilterChip extends StatelessWidget {
  const WebFilterChip({super.key, required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
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
    );
  }
}

class WebBubble extends StatelessWidget {
  const WebBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
    this.isPending = false,
    this.isFailed = false,
  });

  final String text;
  final String time;
  final bool isMe;
  final bool isPending;
  final bool isFailed;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      constraints: BoxConstraints(maxWidth: context.w(320)),
      padding: context.padSym(h: 16, v: 12),
      decoration: BoxDecoration(
        color: isMe ? c.primary : c.white,
        borderRadius: BorderRadius.circular(context.radius(14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: context.appText.text14W400.copyWith(
              color: isMe ? c.onPrimary : c.greyDark,
            ),
          ),
          SizedBox(height: context.h(6)),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              isFailed ? 'Failed' : (isPending ? 'Sending...' : time),
              style: context.appText.text12W400.copyWith(
                color: isFailed
                    ? c.error
                    : (isMe ? c.onPrimary.withValues(alpha: 0.85) : c.greylight),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
