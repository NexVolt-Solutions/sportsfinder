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
            return WebChatContent(
              model: model,
              selectedThreadIndex: _selectedWebThreadIndex,
              messageController: _webMessageController,
              onThreadSelected: (index) {
                setState(() => _selectedWebThreadIndex = index);
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
                ChatListScreenViewModel.upsertThread(
                  userName: activeThread.userName,
                  targetUserId: activeThread.targetUserId,
                  lastMessage: text,
                  lastAt: DateTime.now(),
                );
                _webMessageController.clear();
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
