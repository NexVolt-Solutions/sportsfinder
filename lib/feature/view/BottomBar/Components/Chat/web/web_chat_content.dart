import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
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
    required this.onClearChat,
    required this.onDeleteChat,
  });

  final ChatListScreenViewModel model;
  final int? selectedThreadIndex;
  final TextEditingController messageController;
  final ValueChanged<int?> onThreadSelected;
  final VoidCallback onPickUser;
  final VoidCallback onSendMessage;
  final VoidCallback onClearChat;
  final VoidCallback onDeleteChat;

  @override
  Widget build(BuildContext context) {
    final hasThreads = model.hasThreads;
    final safeSelected =
        hasThreads &&
            selectedThreadIndex != null &&
            selectedThreadIndex! >= 0 &&
            selectedThreadIndex! < model.threads.length
        ? selectedThreadIndex
        : null;
    final activeThread = safeSelected == null
        ? null
        : model.threads[safeSelected];

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
            SizedBox(height: context.h(16)),
            Expanded(
              child: hasThreads
                  ? Row(
                      children: [
                        Expanded(
                          flex: 10,
                          child: WebDashboardPanel(
                            backgroundColor: context.appColors.blue10,
                            padding: context.padSym(h: 12, v: 12),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Expanded(child: _SearchBox()),
                                    SizedBox(width: context.w(10)),
                                    _NewChatButton(onTap: onPickUser),
                                  ],
                                ),
                                SizedBox(height: context.h(8)),
                                Row(
                                  children: [
                                    const WebFilterChip(
                                      label: 'All',
                                      selected: true,
                                    ),
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
                                  child: ListView.separated(
                                    itemCount: model.threads.length,
                                    separatorBuilder: (_, _) =>
                                        SizedBox(height: context.h(8)),
                                    itemBuilder: (context, index) {
                                      final thread = model.threads[index];
                                      final isSelected = index == safeSelected;
                                      return InkWell(
                                        borderRadius: BorderRadius.circular(
                                          context.radius(12),
                                        ),
                                        onTap: () => onThreadSelected(index),
                                        child: Container(
                                          padding: context.padSym(h: 10, v: 10),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? context.appColors.white
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              context.radius(12),
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
                                                radius: context.radius(17),
                                                backgroundColor:
                                                    context.appColors.white,
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: context.w(12)),
                        Expanded(
                          flex: 16,
                          child: WebDashboardPanel(
                            backgroundColor: context.appColors.blue10,
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
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
                                    border: Border(
                                      bottom: BorderSide(
                                        color: context.appColors.greylight
                                            .withValues(alpha: 0.45),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: context.radius(18),
                                        backgroundColor:
                                            context.appColors.blue10,
                                        child: Text(
                                          activeThread != null &&
                                                  activeThread
                                                      .userName
                                                      .isNotEmpty
                                              ? activeThread.userName[0]
                                                    .toUpperCase()
                                              : '',
                                          style: context.appText.text12W500,
                                        ),
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
                                          onSelected: (value) {
                                            if (value == 'clear') {
                                              onClearChat();
                                              return;
                                            }
                                            onDeleteChat();
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem<String>(
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
                                            PopupMenuItem<String>(
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
                                          child: const Icon(
                                            Icons.more_horiz_rounded,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: context.padSym(h: 14, v: 12),
                                    child: activeThread == null
                                        ? Center(
                                            child: Text(
                                              'Select a chat to start messaging.',
                                              style: context.appText.text14W400
                                                  .copyWith(
                                                    color: context
                                                        .appColors
                                                        .greylight,
                                                  ),
                                            ),
                                          )
                                        : Column(
                                            children: [
                                              const Spacer(),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: WebBubble(
                                                  text:
                                                      activeThread.lastMessage,
                                                  time: activeThread.lastTime,
                                                  isMe: true,
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
                                            color: context.appColors.white,
                                            borderRadius: BorderRadius.circular(
                                              context.radius(10),
                                            ),
                                            border: Border.all(
                                              color: context.appColors.primary
                                                  .withValues(alpha: 0.45),
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
                                                v: 12,
                                              ),

                                              // RIGHT SIDE SEND BUTTON
                                              suffixIcon: activeThread == null
                                                  ? null
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 6,
                                                          ),
                                                      child: GestureDetector(
                                                        onTap: () {},
                                                        child: SvgPicture.asset(
                                                          AppAssets
                                                              .chatSendIcon,
                                                          width: context.w(24),
                                                          height: context.w(24),
                                                          color: context
                                                              .appColors
                                                              .primary,
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
                                // Padding(
                                //   padding: context.padSym(h: 14, v: 12),
                                //   child: Row(
                                //     children: [
                                //       Expanded(
                                //         child: Container(
                                //           decoration: BoxDecoration(
                                //             color: context.appColors.white,

                                //             borderRadius: BorderRadius.circular(
                                //               context.radius(10),
                                //             ),

                                //             border: Border.all(
                                //               color: context.appColors.primary
                                //                   .withValues(alpha: 0.45),
                                //             ),
                                //           ),
                                //           child: TextField(
                                //             controller: messageController,
                                //             enabled: activeThread != null,
                                //             decoration: InputDecoration(
                                //               suffix: Icon(
                                //                 Icons.attach_file_rounded,
                                //                 size: 18,
                                //                 color:
                                //                     context.appColors.greylight,
                                //               ),
                                //               hintText: 'Type your message...',
                                //               border: InputBorder.none,
                                //               contentPadding: context.padSym(
                                //                 h: 12,
                                //                 v: 10,
                                //               ),
                                //               suffixIcon: activeThread == null
                                //                   ? null
                                //                   : IconButton(
                                //                       onPressed: onSendMessage,
                                //                       icon: SvgPicture.asset(
                                //                         AppAssets.chatSendIcon,
                                //                         width: context.w(18),
                                //                         height: context.w(18),
                                //                       ),
                                //                     ),
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
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

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.white,
        borderRadius: BorderRadius.circular(context.radius(10)),
        border: Border.all(color: context.appColors.primary, width: 0.8),
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
      padding: context.padSym(h: 12, v: 6),
      decoration: BoxDecoration(
        color: selected ? c.primary : c.white,
        borderRadius: BorderRadius.circular(context.radius(20)),
        border: Border.all(
          color: selected ? c.primary : c.greylight.withValues(alpha: 0.8),
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
  });

  final String text;
  final String time;
  final bool isMe;

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
              time,
              style: context.appText.text12W400.copyWith(
                color: isMe ? c.onPrimary.withValues(alpha: 0.85) : c.greylight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
