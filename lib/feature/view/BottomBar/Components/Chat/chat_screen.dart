import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/chat_route_args.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_screen_view_model.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.matchId, this.targetUserId});

  final String? matchId;
  final String? targetUserId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _boundRealtimeChat = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_boundRealtimeChat) return;

    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final routeMatchId = routeArgs is ChatRouteArgs
        ? (routeArgs.matchId?.trim() ?? '')
        : (routeArgs is String ? routeArgs.trim() : '');
    final routeTargetUserId = routeArgs is ChatRouteArgs
        ? (routeArgs.targetUserId?.trim() ?? '')
        : '';
    final matchId = (widget.matchId?.trim().isNotEmpty ?? false)
        ? widget.matchId!.trim()
        : routeMatchId;
    final targetUserId = (widget.targetUserId?.trim().isNotEmpty ?? false)
        ? widget.targetUserId!.trim()
        : routeTargetUserId;

    if (matchId.isEmpty && targetUserId.isEmpty) return;

    _boundRealtimeChat = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<ChatScreenViewModel>();
      if (matchId.isNotEmpty) {
        vm.bindMatchChat(matchId);
      } else {
        vm.bindDirectChat(targetUserId);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatScreenViewModel>(
      builder: (context, model, child) {
        final subtitle = model.isRealtimeChatBound
            ? (model.isConnected ? model.activeChatSubtitle : 'Connecting...')
            : 'Chat unavailable';

        return Scaffold(
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                top: context.h(10),
                bottom: context.h(16),
                left: context.w(20),
                right: context.w(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.appColors.blue10,
                        borderRadius: BorderRadius.circular(context.radius(12)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(model),
                        decoration: InputDecoration(
                          hintText: AppText.typeAMessage,
                          hintStyle: TextStyle(
                            color: context.appColors.greylight,
                            fontSize: context.text(16),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: context.w(18),
                            vertical: context.h(13),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.w(12)),
                  GestureDetector(
                    onTap: () => _sendMessage(model),
                    child: Container(
                      padding: context.padAll(12),
                      decoration: BoxDecoration(
                        color: context.appColors.primary,
                        borderRadius: BorderRadius.circular(context.radius(12)),
                        boxShadow: [
                          BoxShadow(
                            color: context.appColors.primary.withValues(
                              alpha: 0.35,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(AppAssets.chatSendIcon),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: MainFrame(
            child: Padding(
              padding: context.padSym(h: 20),
              child: Column(
                children: [
                  SizedBox(height: context.h(12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: SvgPicture.asset(AppAssets.backIcon),
                          ),
                          SizedBox(width: context.w(12)),
                          CircleAvatar(
                            radius: context.radius(21),
                            backgroundColor: context.appColors.greylight,
                          ),
                          SizedBox(width: context.w(12)),
                          NormalText(
                            titleText: model.contactName,
                            subText: subtitle,
                            subColor: context.appColors.greylight,
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: SvgPicture.asset(AppAssets.menuIcon),
                      ),
                    ],
                  ),
                  Expanded(
                    child: model.isEmpty
                        ? Center(
                            child: NormalText(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              titleText: 'Chat initiated',
                              subText: 'Say hi to ${model.contactName}',
                              subAlign: TextAlign.center,
                              subColor: context.appColors.greylight,
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(20),
                              vertical: context.h(12),
                            ),
                            itemCount: model.messages.length,
                            itemBuilder: (context, index) {
                              final msg = model.messages[index];
                              final showDate =
                                  index == 0 ||
                                  model.messages[index - 1].date != msg.date;

                              return Column(
                                children: [
                                  if (showDate)
                                    _buildDateChip(context, msg.date),
                                  _buildMessageBubble(
                                    context,
                                    msg,
                                    onRetry: msg.isFailed
                                        ? () => model.retryMessage(msg.localId)
                                        : null,
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                  if (model.errorMessage != null &&
                      model.errorMessage!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: context.h(8)),
                      child: NormalText(
                        titleText: model.errorMessage!,
                        titleColor: context.appColors.error,
                        titleFontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _sendMessage(ChatScreenViewModel model) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    model.sendMessage(text);
    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildDateChip(BuildContext context, String date) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.h(10)),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(8),
            vertical: context.h(4),
          ),
          decoration: BoxDecoration(
            color: context.appColors.primary,
            borderRadius: BorderRadius.circular(context.radius(12)),
          ),
          child: NormalText(
            titleText: date,
            titleColor: context.appColors.onPrimary,
            titleFontSize: 12,
            titleFontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessage msg, {
    VoidCallback? onRetry,
  }) {
    final isMe = msg.isMe;

    return Padding(
      padding: EdgeInsets.only(bottom: context.h(10)),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: context.screenWidth * 0.68),
          padding: context.padSym(h: 12, v: 6),
          decoration: BoxDecoration(
            color: isMe ? context.appColors.primary : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: context.appColors.onSurface.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onRetry,
                behavior: HitTestBehavior.opaque,
                child: NormalText(
                  titleText: msg.text,
                  titleColor: isMe
                      ? context.appColors.onPrimary
                      : context.appColors.onSurface,
                  titleFontWeight: FontWeight.w400,
                  titleFontSize: context.text(16),
                  sizeBoxheight: context.h(4),
                  subText: msg.isFailed
                      ? 'Failed • Tap to retry'
                      : (msg.isPending ? 'Sending...' : msg.time),
                  subColor: msg.isFailed
                      ? context.appColors.error
                      : (isMe
                            ? context.appColors.onPrimary.withValues(alpha: 0.7)
                            : context.appColors.greylight),
                  subFontSize: context.text(12),
                  subFontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
