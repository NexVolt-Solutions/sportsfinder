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
import 'package:sport_finding/Data/Repositories/Chat/direct_messages_repository.dart';
import 'package:sport_finding/feature/widget/app_dialog.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.targetUserId});

  final String? targetUserId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _boundRealtimeChat = false;
  int _lastRenderedMessageCount = 0;
  final Set<String> _selectedMessageLocalIds = <String>{};

  bool get _isSelectionMode => _selectedMessageLocalIds.isNotEmpty;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_boundRealtimeChat) return;

    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    debugPrint('[ChatScreen] routeArgsType=${routeArgs.runtimeType}');
    final routeTargetUserId = routeArgs is ChatRouteArgs
        ? (routeArgs.targetUserId?.trim() ?? '')
        : '';
    final targetUserId = (widget.targetUserId?.trim().isNotEmpty ?? false)
        ? widget.targetUserId!.trim()
        : routeTargetUserId;

    if (targetUserId.isEmpty) {
      debugPrint('[ChatScreen] bind skipped: empty targetUserId');
      return;
    }
    debugPrint('[ChatScreen] binding targetUserId=$targetUserId');

    _boundRealtimeChat = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<ChatScreenViewModel>();
      vm.bindDirectChat(targetUserId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _exitSelectionMode() {
    if (_selectedMessageLocalIds.isEmpty) return;
    debugPrint(
      '[ChatScreen] exitSelectionMode count=${_selectedMessageLocalIds.length}',
    );
    setState(() => _selectedMessageLocalIds.clear());
  }

  void _toggleSelected(ChatMessage msg) {
    final id = msg.localId.trim();
    if (id.isEmpty) return;
    debugPrint(
      '[ChatScreen] toggleSelected localId=$id currentlySelected=${_selectedMessageLocalIds.contains(id)} '
      'selectionCount=${_selectedMessageLocalIds.length} messageId=${msg.messageId} isMe=${msg.isMe} '
      'pending=${msg.isPending} failed=${msg.isFailed} deleted=${msg.isDeleted}',
    );
    setState(() {
      if (_selectedMessageLocalIds.contains(id)) {
        _selectedMessageLocalIds.remove(id);
      } else {
        _selectedMessageLocalIds.add(id);
      }
    });
    debugPrint(
      '[ChatScreen] selectionCountAfter=${_selectedMessageLocalIds.length}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatScreenViewModel>(
      builder: (context, model, child) {
        if (model.messages.length != _lastRenderedMessageCount) {
          _lastRenderedMessageCount = model.messages.length;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || !_scrollController.hasClients) return;
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          });
        }
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
                            onTap: () {
                              if (_isSelectionMode) {
                                _exitSelectionMode();
                                return;
                              }
                              Navigator.pop(context);
                            },
                            child: SvgPicture.asset(AppAssets.backIcon),
                          ),
                          SizedBox(width: context.w(12)),
                          CircleAvatar(
                            radius: context.radius(21),
                            backgroundColor: context.appColors.greylight,
                          ),
                          SizedBox(width: context.w(12)),
                          _isSelectionMode
                              ? NormalText(
                                  titleText:
                                      '${_selectedMessageLocalIds.length} selected',
                                  subText: 'Tap messages to select more',
                                  subColor: context.appColors.greylight,
                                )
                              : NormalText(
                                  titleText: model.contactName,
                                  subText: subtitle,
                                  subColor: context.appColors.greylight,
                                ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (!_isSelectionMode) return;
                          debugPrint(
                            '[ChatScreen] deleteIconTap selectionCount=${_selectedMessageLocalIds.length}',
                          );
                          await _confirmDeleteSelected(context, model);
                        },
                        child: _isSelectionMode
                            ? const Icon(Icons.delete_outline)
                            : SvgPicture.asset(AppAssets.menuIcon),
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
                                    isSelected: _selectedMessageLocalIds
                                        .contains(msg.localId),
                                    isSelectionMode: _isSelectionMode,
                                    onToggleSelected: () => _toggleSelected(msg),
                                    onEnterSelection: () {
                                      final id = msg.localId.trim();
                                      if (id.isEmpty) return;
                                      if (_selectedMessageLocalIds.contains(id)) {
                                        return;
                                      }
                                      debugPrint(
                                        '[ChatScreen] enterSelectionMode localId=$id messageId=${msg.messageId} isMe=${msg.isMe}',
                                      );
                                      setState(() => _selectedMessageLocalIds.add(id));
                                      debugPrint(
                                        '[ChatScreen] selectionCountAfterEnter=${_selectedMessageLocalIds.length}',
                                      );
                                    },
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
    required bool isSelected,
    required bool isSelectionMode,
    required VoidCallback onToggleSelected,
    required VoidCallback onEnterSelection,
    VoidCallback? onRetry,
  }) {
    final isMe = msg.isMe;
    final selectedBg = context.appColors.primary.withValues(alpha: 0.12);

    return Padding(
      padding: EdgeInsets.only(bottom: context.h(10)),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: () {
            if (isSelectionMode) return;
            debugPrint(
              '[ChatScreen] bubbleLongPress localId=${msg.localId} messageId=${msg.messageId} isMe=${msg.isMe}',
            );
            onEnterSelection();
          },
          onTap: () {
            if (!isSelectionMode) return;
            debugPrint(
              '[ChatScreen] bubbleTap (selectionMode) localId=${msg.localId} messageId=${msg.messageId}',
            );
            onToggleSelected();
          },
          child: Container(
            constraints: BoxConstraints(maxWidth: context.screenWidth * 0.68),
            padding: context.padSym(h: 12, v: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? selectedBg
                  : (isMe ? context.appColors.primary : Colors.white),
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
              border: isSelected
                  ? Border.all(
                      color: context.appColors.primary.withValues(alpha: 0.6),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: isSelectionMode ? null : onRetry,
                  behavior: HitTestBehavior.opaque,
                  child: NormalText(
                    titleText: msg.isDeleted ? 'This message was deleted' : msg.text,
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
                              ? context.appColors.onPrimary
                                  .withValues(alpha: 0.7)
                              : context.appColors.greylight),
                    subFontSize: context.text(12),
                    subFontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<ChatMessage> _selectedMessages(ChatScreenViewModel model) {
    if (_selectedMessageLocalIds.isEmpty) return const <ChatMessage>[];
    return model.messages
        .where((m) => _selectedMessageLocalIds.contains(m.localId))
        .toList();
  }

  Future<void> _confirmDeleteSelected(
    BuildContext context,
    ChatScreenViewModel model,
  ) async {
    final selected = _selectedMessages(model);
    if (selected.isEmpty) {
      _exitSelectionMode();
      return;
    }
    await _showDeleteDialog(context, model, selected);
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    ChatScreenViewModel model,
    List<ChatMessage> selected,
  ) async {
    final canDeleteForEveryone = selected.isNotEmpty &&
        selected.every((m) =>
            m.isMe && (m.messageId ?? '').trim().isNotEmpty && !m.isPending);

    final count = selected.length;

    await showAppDialog<void>(
      context,
      title: 'Delete ${count == 1 ? 'message' : 'messages'}?',
      message: count == 1
          ? 'Choose how you want to delete this message.'
          : 'Choose how you want to delete $count messages.',
      actions: [
        AppDialogAction(
          label: 'Delete for me',
          isDefault: true,
          onPressed: (dialogContext) async {
            Navigator.pop(dialogContext);
            try {
              await model.deleteMessages(
                selected,
                scope: DeleteMessageScope.me,
              );
              if (mounted) _exitSelectionMode();
            } catch (_) {}
          },
        ),
        if (canDeleteForEveryone)
          AppDialogAction(
            label: 'Delete for everyone',
            isDestructive: true,
            onPressed: (dialogContext) async {
              Navigator.pop(dialogContext);
              try {
                await model.deleteMessages(
                  selected,
                  scope: DeleteMessageScope.both,
                );
                if (mounted) _exitSelectionMode();
              } catch (_) {}
            },
          ),
        AppDialogAction(
          label: 'Cancel',
          onPressed: (dialogContext) => Navigator.pop(dialogContext),
        ),
      ],
    );
  }
}
