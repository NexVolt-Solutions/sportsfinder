import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/chat_route_args.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_list_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/webwidget/web_chat_content.dart';

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
  int _selectedWebThreadIndex = 0;

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
    );
    if (kIsWeb && widget.embedInBottomBar) {
      setState(() => _selectedWebThreadIndex = 0);
      return;
    }
    await Navigator.pushNamed(
      context,
      RoutesName.chatScreen,
      arguments: selected,
    );
  }

  @override
  void dispose() {
    _webMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _safeVm,
      child: Consumer<ChatListScreenViewModel>(
        builder: (context, model, _) {
          if (kIsWeb && widget.embedInBottomBar) {
<<<<<<< HEAD
            return WebChatContent(
              model: model,
              selectedThreadIndex: _selectedWebThreadIndex,
              messageController: _webMessageController,
              onThreadSelected: (index) {
                setState(() => _selectedWebThreadIndex = index);
              },
              onPickUser: _pickAndOpenUser,
              onSendMessage: () {
                final hasThreads = model.hasThreads;
                if (!hasThreads) return;
                final safeSelected = _selectedWebThreadIndex.clamp(
                  0,
                  model.threads.length - 1,
                );
                final activeThread = model.threads[safeSelected];
                final text = _webMessageController.text.trim();
                if (text.isEmpty) return;
                ChatListScreenViewModel.upsertThread(
                  userName: activeThread.userName,
                  matchId: activeThread.matchId,
                  lastMessage: text,
                  lastAt: DateTime.now(),
                );
                _webMessageController.clear();
              },
=======
            final hasThreads = model.hasThreads;
            final safeSelected = hasThreads
                ? _selectedWebThreadIndex.clamp(0, model.threads.length - 1)
                : 0;
            final activeThread = hasThreads ? model.threads[safeSelected] : null;
            return Padding(
              padding: context.padSym(h: 20, v: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WebDashboardTitle(
                    title: 'Chat',
                    subtitle: 'Start messaging now',
                    trailing: null,
                  ),
                  SizedBox(height: context.h(8)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'New chat',
                      onPressed: _pickAndOpenUser,
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
                                      hintStyle: context.appText.text12W400
                                          .copyWith(
                                            color: context.appColors.greylight,
                                          ),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        color: context.appColors.greylight,
                                        size: 18,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: context.padSym(
                                        h: 8,
                                        v: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: context.h(8)),
                                Row(
                                  children: [
                                    _WebFilterChip(label: 'All', selected: true),
                                    SizedBox(width: context.w(6)),
                                    _WebFilterChip(label: 'Unread'),
                                    SizedBox(width: context.w(6)),
                                    _WebFilterChip(label: 'Favorites'),
                                    SizedBox(width: context.w(6)),
                                    _WebFilterChip(label: 'Group'),
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
                                            final t = model.threads[index];
                                            final isSelected =
                                                index == safeSelected;
                                            return InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    context.radiusR(12),
                                                  ),
                                              onTap: () => setState(
                                                () => _selectedWebThreadIndex =
                                                    index,
                                              ),
                                              child: Container(
                                                padding: context.padSym(
                                                  h: 10,
                                                  v: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? context.appColors.blue10
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        context.radiusR(12),
                                                      ),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? context.appColors.primary
                                                        : context
                                                              .appColors
                                                              .greylight
                                                              .withValues(
                                                                alpha: 0.25,
                                                              ),
                                                    width: 0.8,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: context.radiusR(
                                                        17,
                                                      ),
                                                      backgroundColor: context
                                                          .appColors
                                                          .greylight
                                                          .withValues(
                                                            alpha: 0.4,
                                                          ),
                                                      child: Text(
                                                        t.userName.isNotEmpty
                                                            ? t.userName[0]
                                                                  .toUpperCase()
                                                            : 'U',
                                                        style: context
                                                            .appText
                                                            .text12W500,
                                                      ),
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
                                                            t.userName,
                                                            maxLines: 1,
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            style: context
                                                                .appText
                                                                .text14W500,
                                                          ),
                                                          SizedBox(
                                                            height: context.h(2),
                                                          ),
                                                          Text(
                                                            t.lastMessage,
                                                            maxLines: 1,
                                                            overflow: TextOverflow
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
                                                      t.lastTime,
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
                                                  color: context
                                                      .appColors
                                                      .greylight,
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
                            padding: context.padSym(h: 0, v: 0),
                            child: Column(
                              children: [
                                Container(
                                  padding: context.padSym(h: 14, v: 10),
                                  decoration: BoxDecoration(
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
                                        radius: context.radiusR(18),
                                        backgroundColor: context
                                            .appColors
                                            .greylight
                                            .withValues(alpha: 0.35),
                                        child: Text(
                                          activeThread != null &&
                                                  activeThread.userName.isNotEmpty
                                              ? activeThread.userName[0]
                                                    .toUpperCase()
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
                                                    color: context
                                                        .appColors
                                                        .greylight,
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
                                            child: _WebBubble(
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
                                                  color: context
                                                      .appColors
                                                      .greylight,
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
                                            controller: _webMessageController,
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
                                            : () {
                                                final text = _webMessageController
                                                    .text
                                                    .trim();
                                                if (text.isEmpty) return;
                                                ChatListScreenViewModel.upsertThread(
                                                  userName:
                                                      activeThread.userName,
                                                  matchId:
                                                      activeThread.matchId,
                                                  targetUserId:
                                                      activeThread.targetUserId,
                                                  lastMessage: text,
                                                  lastAt: DateTime.now(),
                                                );
                                                _webMessageController.clear();
                                              },
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
>>>>>>> e64cebb64718cf5002de90ee598a73a08e4e0d08
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
                                      matchId: t.matchId,
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
                                      context.radiusR(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: context.radiusR(22),
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
