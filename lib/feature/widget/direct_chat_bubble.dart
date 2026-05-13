import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_screen_view_model.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

bool _isProbablyImage(String? url, String? mime) {
  final u = (url ?? '').trim().toLowerCase();
  final m = (mime ?? '').trim().toLowerCase();
  if (u.isEmpty && m.isEmpty) return false;

  if (u.endsWith('.jpg') ||
      u.endsWith('.jpeg') ||
      u.endsWith('.png') ||
      u.endsWith('.webp') ||
      u.endsWith('.gif')) {
    return true;
  }
  if (u.endsWith('.pdf') ||
      u.endsWith('.doc') ||
      u.endsWith('.docx') ||
      u.endsWith('.xls') ||
      u.endsWith('.xlsx') ||
      u.endsWith('.ppt') ||
      u.endsWith('.pptx') ||
      u.endsWith('.zip') ||
      u.endsWith('.rar')) {
    return false;
  }

  if (m == 'image/pdf' || m == 'application/pdf') return false;
  return m.startsWith('image/');
}

/// Display payload for [DirectChatBubble] (mobile [ChatMessage] or web plain text).
class DirectChatBubbleModel {
  const DirectChatBubbleModel({
    required this.titleText,
    required this.isMe,
    required this.isDeleted,
    required this.isPending,
    required this.isFailed,
    required this.effectiveType,
    required this.timeLabel,
    this.readAt,
    this.deliveredAt,
    this.mediaUrl,
    this.thumbnailUrl,
    this.fileName,
  });

  final String titleText;
  final bool isMe;
  final bool isDeleted;
  final bool isPending;
  final bool isFailed;
  final ChatMessageType effectiveType;
  final String timeLabel;
  final DateTime? readAt;
  final DateTime? deliveredAt;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;

  factory DirectChatBubbleModel.fromChatMessage(
    ChatMessage msg,
  ) {
    final hasMedia = (msg.mediaUrl ?? '').trim().isNotEmpty;
    final inferredType = hasMedia
        ? (_isProbablyImage(msg.mediaUrl ?? msg.thumbnailUrl, msg.mimeType)
              ? ChatMessageType.image
              : ChatMessageType.file)
        : msg.type;
    final effectiveType =
        (msg.type == ChatMessageType.text && hasMedia) ? inferredType : msg.type;

    final titleText = msg.isDeleted
        ? (msg.isMe ? '' : AppText.chatMessageWasDeleted)
        : (effectiveType == ChatMessageType.text
              ? msg.text
              : (effectiveType == ChatMessageType.image
                    ? ''
                    : ((msg.fileName ?? 'File').trim().isEmpty
                          ? 'File'
                          : (msg.fileName ?? 'File').trim())));

    return DirectChatBubbleModel(
      titleText: titleText,
      isMe: msg.isMe,
      isDeleted: msg.isDeleted,
      isPending: msg.isPending,
      isFailed: msg.isFailed,
      effectiveType: effectiveType,
      timeLabel: msg.time,
      readAt: msg.readAt,
      deliveredAt: msg.deliveredAt,
      mediaUrl: msg.mediaUrl,
      thumbnailUrl: msg.thumbnailUrl,
      fileName: msg.fileName,
    );
  }

  /// Text-only row (e.g. web embedded chat).
  factory DirectChatBubbleModel.plainText({
    required String text,
    required String time,
    required bool isMe,
    bool isPending = false,
    bool isFailed = false,
    bool isDeleted = false,
    DateTime? readAt,
    DateTime? deliveredAt,
  }) {
    return DirectChatBubbleModel(
      titleText: text,
      isMe: isMe,
      isDeleted: isDeleted,
      isPending: isPending,
      isFailed: isFailed,
      effectiveType: ChatMessageType.text,
      timeLabel: time,
      readAt: readAt,
      deliveredAt: deliveredAt,
    );
  }
}

/// Shared chat bubble for mobile and web: max width cap, height follows content.
class DirectChatBubble extends StatelessWidget {
  const DirectChatBubble({
    super.key,
    required this.maxWidth,
    required this.model,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onLongPress,
    this.onTap,
    this.onRetryTap,
    this.onImageTap,
  });

  final double maxWidth;
  final DirectChatBubbleModel model;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final VoidCallback? onRetryTap;
  final VoidCallback? onImageTap;

  String _subtitleLine(BuildContext context) {
    if (model.isFailed) {
      return onRetryTap != null ? 'Failed • Tap to retry' : 'Failed';
    }
    if (model.isPending) return 'Sending...';
    if (model.isMe) return '';
    return model.timeLabel;
  }

  bool get _showReceiptRow =>
      model.isMe &&
      !model.isDeleted &&
      !model.isFailed &&
      !model.isPending &&
      model.effectiveType == ChatMessageType.text;

  @override
  Widget build(BuildContext context) {
    // Delete-for-everyone: only the **other** user sees the tombstone; sender sees nothing.
    if (model.isDeleted && model.isMe) {
      return const SizedBox.shrink();
    }

    final isMe = model.isMe;
    final selectedBg = context.appColors.primary.withValues(alpha: 0.12);
    final subLine = _subtitleLine(context);

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: isSelectionMode ? null : onRetryTap,
                behavior: HitTestBehavior.opaque,
                child: NormalText(
                  titleText: model.titleText,
                  titleColor: isMe
                      ? context.appColors.onPrimary
                      : context.appColors.onSurface,
                  titleFontWeight: FontWeight.w400,
                  titleFontSize: context.text(16),
                  sizeBoxheight: context.h(4),
                  subText: subLine.isEmpty ? null : subLine,
                  subColor: model.isFailed
                      ? context.appColors.error
                      : (isMe
                            ? context.appColors.onPrimary.withValues(alpha: 0.7)
                            : context.appColors.greylight),
                  subFontSize: context.text(12),
                  subFontWeight: FontWeight.w400,
                ),
              ),
              if (_showReceiptRow)
                Padding(
                  padding: EdgeInsets.only(top: context.h(4)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        model.timeLabel,
                        style: context.appText.text12W400.copyWith(
                          color: context.appColors.onPrimary
                              .withValues(alpha: 0.72),
                        ),
                      ),
                      SizedBox(width: context.w(4)),
                      Builder(
                        builder: (context) {
                          final read = model.readAt;
                          final del = model.deliveredAt;
                          final isRead = read != null;
                          // WhatsApp-style: double tick once the server accepted the message
                          // ([deliveredAt], or [sentAt] via receipt merge) — not gated on peer
                          // "online". Single tick only briefly before that ack (no delivery signal).
                          // No network → row stays pending/failed ("Sending…" / retry), not this state.
                          final hasDeliverySignal = del != null;
                          final useDoubleTick = isRead || hasDeliverySignal;
                          final iconData = useDoubleTick
                              ? Icons.done_all_rounded
                              : Icons.done_rounded;
                          final Color tickColor;
                          if (isRead) {
                            tickColor = Colors.white;
                          } else if (hasDeliverySignal) {
                            tickColor =
                                Colors.white.withValues(alpha: 0.55);
                          } else {
                            tickColor = context.appColors.onPrimary
                                .withValues(alpha: 0.72);
                          }
                          return Icon(
                            iconData,
                            size: context.w(14),
                            color: tickColor,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              if (!model.isDeleted &&
                  model.effectiveType == ChatMessageType.image)
                Padding(
                  padding: EdgeInsets.only(top: context.h(8)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: InkWell(
                        onTap: isSelectionMode ? null : onImageTap,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              (model.mediaUrl ?? model.thumbnailUrl ?? '')
                                  .trim(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: context.appColors.blue10,
                                alignment: Alignment.center,
                                child: Text(
                                  'Image unavailable',
                                  style: context.appText.text12W500.copyWith(
                                    color: context.appColors.greylight,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: context.w(8),
                              bottom: context.h(8),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.w(8),
                                  vertical: context.h(4),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(
                                    context.radius(12),
                                  ),
                                ),
                                child: Text(
                                  model.timeLabel,
                                  style: context.appText.text12W500.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (!model.isDeleted && model.effectiveType == ChatMessageType.file)
                Padding(
                  padding: EdgeInsets.only(top: context.h(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        Icons.insert_drive_file_outlined,
                        size: 18,
                        color: isMe
                            ? context.appColors.onPrimary.withValues(alpha: 0.85)
                            : context.appColors.greyDark,
                      ),
                      SizedBox(width: context.w(8)),
                      Expanded(
                        child: Text(
                          (model.fileName ?? 'File').trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.appText.text12W600.copyWith(
                            color: isMe
                                ? context.appColors.onPrimary
                                : context.appColors.onSurface,
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
    );
  }
}
