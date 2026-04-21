import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/Repositories/MatchInvitation/invite_action_repository.dart';
import 'package:sport_finding/Data/model/Notification/notification_model.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Network/notification_service.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/core/utils/logger.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final InviteActionRepository _inviteActionRepository =
      InviteActionRepository();
  final Map<String, bool> _actionLoading = <String, bool>{};
  final Map<String, _ResolvedInviteAction> _resolvedInviteActions =
      <String, _ResolvedInviteAction>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationService>().fetchNotifications();
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    final local = date.toLocal();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final local = date.toLocal();
    return local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day;
  }

  bool _isEarlier(DateTime date) => !_isToday(date) && !_isYesterday(date);

  String _relativeLabel(DateTime date) {
    final local = date.toLocal();
    final diff = DateTime.now().difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) {
      final minutes = diff.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      final hours = diff.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }
    final days = diff.inDays;
    if (days <= 1) return AppText.yesterday;
    return '$days day${days == 1 ? '' : 's'} ago';
  }

  Future<void> _handleInvitationAction(
    NotificationModel item,
    bool accept,
  ) async {
    final matchId = item.matchId;
    final actionLabel = accept ? 'accept' : 'decline';
    AppLogger.info(
      'Notification action tapped: $actionLabel '
      'for notificationId=${item.id}, matchId=$matchId',
      tag: 'NotificationsScreen',
    );
    if (matchId.isEmpty) {
      if (!mounted) return;
      AppSnackBar.show('Match id is missing');
      return;
    }

    setState(() {
      _actionLoading[item.id] = true;
    });

    try {
      AppLogger.debug(
        'Hitting $actionLabel invite API for matchId=$matchId',
        tag: 'NotificationsScreen',
      );
      final response = accept
          ? await _inviteActionRepository.acceptInvite(matchId: matchId)
          : await _inviteActionRepository.declineInvite(matchId: matchId);

      AppLogger.success(
        '${accept ? 'Accept' : 'Decline'} invite API hit succeeded for '
        'notificationId=${item.id}, matchId=$matchId',
        tag: 'NotificationsScreen',
      );
      AppLogger.debug(
        'Notification action response: ${response.message}',
        tag: 'NotificationsScreen',
      );

      if (accept) {
        AppLogger.info(
          'Accepted invitation will appear in participated players after '
          'the roster is refreshed for matchId=$matchId',
          tag: 'NotificationsScreen',
        );
      } else {
        AppLogger.info(
          'Declined invitation completed for matchId=$matchId; '
          'no participant will be stored',
          tag: 'NotificationsScreen',
        );
      }

      final notificationService = context.read<NotificationService>();
      await notificationService.markAsRead(item.id);

      if (!mounted) return;
      setState(() {
        _resolvedInviteActions[item.id] = accept
            ? _ResolvedInviteAction.accepted
            : _ResolvedInviteAction.declined;
      });

      AppLogger.info(
        'Notification invite actions hidden after $actionLabel action: '
        'notificationId=${item.id}',
        tag: 'NotificationsScreen',
      );

      AppSnackBar.show(
        response.message.isNotEmpty
            ? response.message
            : (accept ? 'Invitation accepted' : 'Invitation declined'),
      );
    } catch (e) {
      AppLogger.error(
        '$actionLabel invite API failed for notificationId=${item.id}, '
        'matchId=$matchId',
        tag: 'NotificationsScreen',
        error: e,
      );
      if (!mounted) return;
      AppSnackBar.show(e.toString());
    } finally {
      if (!mounted) return;
      setState(() {
        _actionLoading.remove(item.id);
      });
    }
  }

  Future<void> _handleNotificationTap(NotificationModel item) async {
    if (item.isRead || item.id.trim().isEmpty) return;

    try {
      await context.read<NotificationService>().markAsRead(item.id);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(e.toString());
    }
  }

  Future<void> _handleReadAll() async {
    final service = context.read<NotificationService>();
    if (!service.hasUnread) return;

    try {
      final message = await service.markAllAsRead();
      if (!mounted) return;
      AppSnackBar.show(
        message != null && message.isNotEmpty
            ? message
            : AppText.allNotificationsMarkedRead,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(e.toString());
    }
  }

  Future<void> _handleClearMessages() async {
    final service = context.read<NotificationService>();
    if (service.notifications.isEmpty) return;
    service.clearAllNotifications();
    if (!mounted) return;
    setState(() {
      _actionLoading.clear();
      _resolvedInviteActions.clear();
    });
    AppSnackBar.show('All messages cleared');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final service = context.watch<NotificationService>();
    final visibleNotifications = service.notifications;
    final todayItems = visibleNotifications
        .where(_isTodayNotification)
        .toList();
    final yesterdayItems = visibleNotifications
        .where(_isYesterdayNotification)
        .toList();
    final earlierItems = visibleNotifications
        .where(_isEarlierNotification)
        .toList();

    return Scaffold(
      body: MainFrame(
        child: service.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: context.padSym(h: 20, v: 20),
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: context.w(28),
                          height: context.w(28),
                          child: Center(
                            child: SvgPicture.asset(
                              AppAssets.backIcon,
                              colorFilter: ColorFilter.mode(
                                c.greyDark,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: NormalText(
                            titleText: AppText.notifications,
                            titleStyle: context.appText.text18W600,
                          ),
                        ),
                      ),
                      PopupMenuButton<_NotificationMenuAction>(
                        icon: Icon(
                          Icons.more_vert,
                          color: c.greyDark,
                          size: context.w(22),
                        ),
                        onSelected: (action) {
                          switch (action) {
                            case _NotificationMenuAction.readAll:
                              _handleReadAll();
                              break;
                            case _NotificationMenuAction.clearMessages:
                              _handleClearMessages();
                              break;
                          }
                        },
                        itemBuilder: (_) => <PopupMenuEntry<_NotificationMenuAction>>[
                          PopupMenuItem<_NotificationMenuAction>(
                            value: _NotificationMenuAction.readAll,
                            enabled: service.hasUnread && !service.isMarkingAllRead,
                            child: Text(
                              service.isMarkingAllRead
                                  ? '${AppText.readAll}...'
                                  : AppText.readAll,
                            ),
                          ),
                          PopupMenuItem<_NotificationMenuAction>(
                            value: _NotificationMenuAction.clearMessages,
                            enabled: visibleNotifications.isNotEmpty,
                            child: const Text('Clear messages'),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: context.h(12)),
                  if (todayItems.isNotEmpty) ...[
                    NormalText(
                      titleText: AppText.today,
                      titleStyle: context.appText.text16W600,
                    ),
                    SizedBox(height: context.h(10)),
                    ...todayItems.map(
                      (n) => _NotificationCard(
                        item: _NotificationItem.fromModel(
                          n,
                          rightLabel: _relativeLabel(n.createdAt),
                          resolvedInviteAction: _resolvedInviteActions[n.id],
                        ),
                        isActionLoading: _actionLoading[n.id] == true,
                        onTap: () => _handleNotificationTap(n),
                        onPrimaryTap: n.isInvitation
                            ? () => _handleInvitationAction(n, true)
                            : null,
                        onSecondaryTap: n.isInvitation
                            ? () => _handleInvitationAction(n, false)
                            : null,
                      ),
                    ),
                    SizedBox(height: context.h(8)),
                  ],
                  if (yesterdayItems.isNotEmpty) ...[
                    NormalText(
                      titleText: AppText.yesterday,
                      titleStyle: context.appText.text16W600,
                    ),
                    SizedBox(height: context.h(10)),
                    ...yesterdayItems.map(
                      (n) => _NotificationCard(
                        item: _NotificationItem.fromModel(
                          n,
                          rightLabel: _relativeLabel(n.createdAt),
                          resolvedInviteAction: _resolvedInviteActions[n.id],
                        ),
                        isActionLoading: _actionLoading[n.id] == true,
                        onTap: () => _handleNotificationTap(n),
                        onPrimaryTap: n.isInvitation
                            ? () => _handleInvitationAction(n, true)
                            : null,
                        onSecondaryTap: n.isInvitation
                            ? () => _handleInvitationAction(n, false)
                            : null,
                      ),
                    ),
                  ],
                  if (earlierItems.isNotEmpty) ...[
                    SizedBox(height: context.h(8)),
                    NormalText(
                      titleText: AppText.earlier,
                      titleStyle: context.appText.text16W600,
                    ),
                    SizedBox(height: context.h(10)),
                    ...earlierItems.map(
                      (n) => _NotificationCard(
                        item: _NotificationItem.fromModel(
                          n,
                          rightLabel: _relativeLabel(n.createdAt),
                          resolvedInviteAction: _resolvedInviteActions[n.id],
                        ),
                        isActionLoading: _actionLoading[n.id] == true,
                        onTap: () => _handleNotificationTap(n),
                        onPrimaryTap: n.isInvitation
                            ? () => _handleInvitationAction(n, true)
                            : null,
                        onSecondaryTap: n.isInvitation
                            ? () => _handleInvitationAction(n, false)
                            : null,
                      ),
                    ),
                  ],
                  if (visibleNotifications.isEmpty)
                    Padding(
                      padding: context.padSym(v: 40),
                      child: Center(
                        child: Text(
                          'No notifications found',
                          style: context.appText.text14W400.copyWith(
                            color: c.greyDark,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  bool _isTodayNotification(NotificationModel item) => _isToday(item.createdAt);
  bool _isYesterdayNotification(NotificationModel item) =>
      _isYesterday(item.createdAt);
  bool _isEarlierNotification(NotificationModel item) =>
      _isEarlier(item.createdAt);
}

class _NotificationItem {
  const _NotificationItem({
    required this.avatarLetter,
    required this.title,
    required this.rightLabel,
    required this.isRead,
    required this.showActions,
    this.subtitle,
    this.showLocationIcon = false,
    this.primaryActionText,
    this.secondaryActionText,
    this.isPrimaryActionFilled = true,
  });

  final String avatarLetter;
  final String title;
  final String rightLabel;
  final bool isRead;
  final bool showActions;
  final String? subtitle;
  final bool showLocationIcon;
  final String? primaryActionText;
  final String? secondaryActionText;
  final bool isPrimaryActionFilled;

  factory _NotificationItem.fromModel(
    NotificationModel model, {
    required String rightLabel,
    _ResolvedInviteAction? resolvedInviteAction,
  }) {
    final subtitle = model.displaySubtitle;
    final showActions =
        model.isInvitation && resolvedInviteAction == null;
    return _NotificationItem(
      avatarLetter: model.avatarLetter,
      title: model.displayTitle,
      rightLabel: rightLabel,
      isRead: model.isRead,
      showActions: showActions,
      subtitle: subtitle.isEmpty ? null : subtitle,
      showLocationIcon: model.locationName.isNotEmpty,
      primaryActionText: showActions ? 'Accept' : null,
      secondaryActionText: showActions ? 'Decline' : null,
      isPrimaryActionFilled: true,
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    this.isActionLoading = false,
    this.onTap,
    this.onPrimaryTap,
    this.onSecondaryTap,
  });

  final _NotificationItem item;
  final bool isActionLoading;
  final VoidCallback? onTap;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final hasActions = item.showActions && item.primaryActionText != null;

    return CardWidget(
      onTap: onTap,
      padding: context.padSym(h: 12, v: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 1,
            shape: CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                item.avatarLetter,
                style: context.appText.text18W500.copyWith(color: c.primary),
              ),
            ),
          ),
          SizedBox(width: context.w(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: context.appText.text18W500.copyWith(
                          fontSize: 31 * context.scaleWidth / 2,
                          color: c.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(width: context.w(8)),
                    Text(
                      item.rightLabel,
                      style: context.appText.text16W400.copyWith(
                        color: item.isRead ? c.greyDark : c.primary,
                      ),
                    ),
                    if (!item.isRead) ...[
                      SizedBox(width: context.w(6)),
                      Container(
                        width: context.w(8),
                        height: context.w(8),
                        decoration: BoxDecoration(
                          color: c.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.subtitle != null) ...[
                  SizedBox(height: context.h(3)),
                  Row(
                    children: [
                      if (item.showLocationIcon) ...[
                        Icon(
                          Icons.location_on_outlined,
                          size: context.w(14),
                          color: c.greylight,
                        ),
                        SizedBox(width: context.w(4)),
                      ],
                      Expanded(
                        child: Text(
                          item.subtitle!,
                          style: context.appText.text16W500.copyWith(
                            color: c.greyDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (hasActions) ...[
                  SizedBox(height: context.h(8)),
                  if (isActionLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    Row(
                      children: [
                        _ActionPill(
                          text: item.primaryActionText!,
                          filled: item.isPrimaryActionFilled,
                          onTap: onPrimaryTap,
                        ),
                        if (item.secondaryActionText != null) ...[
                          SizedBox(width: context.w(8)),
                          _ActionPill(
                            text: item.secondaryActionText!,
                            filled: false,
                            onTap: onSecondaryTap,
                          ),
                        ],
                      ],
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.text, required this.filled, this.onTap});

  final String text;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.radiusR(14)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(12),
          vertical: context.h(3),
        ),
        decoration: BoxDecoration(
          color: filled ? c.primary : c.onPrimary.withValues(alpha: 0.0),
          borderRadius: BorderRadius.circular(context.radiusR(14)),
          border: Border.all(color: c.primary, width: 1.1),
        ),
        child: Text(
          text,
          style: context.appText.text16W500.copyWith(
            color: filled ? c.onPrimary : c.primary,
          ),
        ),
      ),
    );
  }
}

enum _ResolvedInviteAction { accepted, declined }

enum _NotificationMenuAction { readAll, clearMessages }
