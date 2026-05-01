import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_list_screen_view_model.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/webwidget/web_dashboard_widgets.dart';

class WebChatContent extends StatelessWidget {
  const WebChatContent({
    super.key,
    required this.model,
    required this.selectedThreadIndex,
    required this.messageController,
    required this.onThreadSelected,
    required this.onPickUser,
    required this.onSendMessage,
  });

  final ChatListScreenViewModel model;
  final int selectedThreadIndex;
  final TextEditingController messageController;
  final ValueChanged<int> onThreadSelected;
  final VoidCallback onPickUser;
  final VoidCallback onSendMessage;

  @override
  Widget build(BuildContext context) {
    final hasThreads = model.hasThreads;
    final safeSelected = hasThreads
        ? selectedThreadIndex.clamp(0, model.threads.length - 1)
        : 0;
    final activeThread = hasThreads ? model.threads[safeSelected] : null;

    return MainFrame(
      showDecorationLayer: false,
      child: Padding(
        padding: context.padSym(h: 20, v: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WebDashboardTitle(
              title: 'Chat',
              subtitle: 'Start messaging now',
            ),
            SizedBox(height: context.h(8)),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'New chat',
                onPressed: onPickUser,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: WebDashboardPanel(
                      padding: context.padSym(h: 12, v: 12),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: context.appColors.blue10,
                              borderRadius: BorderRadius.circular(
                                context.radiusR(10),
                              ),
                              border: Border.all(
                                color: context.appColors.greylight,
                                width: 0.8,
                              ),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Start or new chat now..',
                                hintStyle: context.appText.text12W400.copyWith(
                                  color: context.appColors.greylight,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: context.appColors.greylight,
                                  size: 18,
                                ),
                                border: InputBorder.none,
                                contentPadding: context.padSym(h: 8, v: 10),
                              ),
                            ),
                          ),
                          SizedBox(height: context.h(8)),
                          Row(
                            children: [
                              const WebFilterChip(label: 'All', selected: true),
                              SizedBox(width: context.w(6)),
                              const WebFilterChip(label: 'Unread'),
                              SizedBox(width: context.w(6)),
                              const WebFilterChip(label: 'Favorites'),
                              SizedBox(width: context.w(6)),
                              const WebFilterChip(label: 'Group'),
                            ],
                          ),
                          SizedBox(height: context.h(8)),
                          Expanded(
                            child: hasThreads
                                ? ListView.separated(
                                    itemCount: model.threads.length,
                                    separatorBuilder: (_, _) =>
                                        SizedBox(height: context.h(8)),
                                    itemBuilder: (context, index) {
                                      final thread = model.threads[index];
                                      final isSelected = index == safeSelected;
                                      return InkWell(
                                        borderRadius: BorderRadius.circular(
                                          context.radiusR(12),
                                        ),
                                        onTap: () => onThreadSelected(index),
                                        child: Container(
                                          padding: context.padSym(h: 10, v: 10),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? context.appColors.blue10
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              context.radiusR(12),
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? context.appColors.primary
                                                  : context.appColors.greylight
                                                        .withValues(
                                                          alpha: 0.25,
                                                        ),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: context.radiusR(17),
                                                backgroundColor: context
                                                    .appColors
                                                    .greylight
                                                    .withValues(alpha: 0.4),
                                                child: Text(
                                                  thread.userName.isNotEmpty
                                                      ? thread.userName[0]
                                                            .toUpperCase()
                                                      : 'U',
                                                  style: context
                                                      .appText
                                                      .text12W500,
                                                ),
                                              ),
                                              SizedBox(width: context.w(10)),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      thread.userName,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: context
                                                          .appText
                                                          .text14W500,
                                                    ),
                                                    SizedBox(
                                                      height: context.h(2),
                                                    ),
                                                    Text(
                                                      thread.lastMessage,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                              SizedBox(width: context.w(6)),
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
                                  )
                                : Center(
                                    child: Text(
                                      'No chats yet',
                                      style: context.appText.text14W400
                                          .copyWith(
                                            color: context.appColors.greylight,
                                          ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: context.w(12)),
                  Expanded(
                    flex: 14,
                    child: WebDashboardPanel(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Container(
                            padding: context.padSym(h: 14, v: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: context.appColors.greylight.withValues(
                                    alpha: 0.45,
                                  ),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: context.radiusR(18),
                                  backgroundColor: context.appColors.greylight
                                      .withValues(alpha: 0.35),
                                  child: Text(
                                    activeThread != null &&
                                            activeThread.userName.isNotEmpty
                                        ? activeThread.userName[0].toUpperCase()
                                        : 'C',
                                    style: context.appText.text12W500,
                                  ),
                                ),
                                SizedBox(width: context.w(10)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activeThread?.userName ??
                                            'Select a conversation',
                                        style: context.appText.text14W500,
                                      ),
                                      Text(
                                        'Start messaging now',
                                        style: context.appText.text12W400
                                            .copyWith(
                                              color:
                                                  context.appColors.greylight,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.more_horiz_rounded),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: context.padSym(h: 14, v: 12),
                              child: Column(
                                children: [
                                  const Spacer(),
                                  if (activeThread != null) ...[
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: WebBubble(
                                        text: activeThread.lastMessage,
                                        time: activeThread.lastTime,
                                        isMe: true,
                                      ),
                                    ),
                                  ] else
                                    Text(
                                      'Start by selecting or creating a chat',
                                      style: context.appText.text14W400
                                          .copyWith(
                                            color: context.appColors.greylight,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: context.padSym(h: 14, v: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: context.appColors.blue10,
                                      borderRadius: BorderRadius.circular(
                                        context.radiusR(10),
                                      ),
                                      border: Border.all(
                                        color: context.appColors.greylight
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: messageController,
                                      enabled: activeThread != null,
                                      decoration: InputDecoration(
                                        hintText: 'Type your message...',
                                        border: InputBorder.none,
                                        contentPadding: context.padSym(
                                          h: 12,
                                          v: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: context.w(10)),
                                IconButton(
                                  onPressed: activeThread == null
                                      ? null
                                      : onSendMessage,
                                  icon: Icon(
                                    Icons.send_outlined,
                                    color: context.appColors.primary,
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
          ],
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
  });

  final String text;
  final String time;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: context.screenWidth * 0.25),
      padding: context.padSym(h: 12, v: 8),
      decoration: BoxDecoration(
        color: isMe ? context.appColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(context.radiusR(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: context.appText.text12W500.copyWith(
              color: isMe
                  ? context.appColors.onPrimary
                  : context.appColors.onSurface,
            ),
          ),
          SizedBox(height: context.h(4)),
          Text(
            time,
            style: context.appText.text12W400.copyWith(
              color: isMe
                  ? context.appColors.onPrimary.withValues(alpha: 0.8)
                  : context.appColors.greylight,
            ),
          ),
        ],
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
    return Container(
      padding: context.padSym(h: 10, v: 4),
      decoration: BoxDecoration(
        color: selected ? context.appColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(context.radiusR(14)),
        border: Border.all(
          color: selected
              ? context.appColors.primary
              : context.appColors.greylight.withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: context.appText.text12W400.copyWith(
          color: selected
              ? context.appColors.onPrimary
              : context.appColors.greyDark,
        ),
      ),
    );
  }
}
