import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final List<_NotificationItem> _todayItems = [
    _NotificationItem(
      avatarLetter: 'R',
      title: AppText.rimshaInvitedYouToJoinABasketballMatch,
      rightLabel: AppText.twoMinutesAgo,
      subtitle: AppText.centralPark,
      showLocationIcon: true,
      primaryActionText: 'Accept',
      secondaryActionText: 'Decline',
      isPrimaryActionFilled: true,
    ),
    _NotificationItem(
      avatarLetter: 'H',
      title: AppText.hinaJoinedYourMatch,
      rightLabel: AppText.fifteenMinutesAgo,
      subtitle: AppText.basketball,
    ),
    _NotificationItem(
      avatarLetter: 'T',
      title: AppText.taifLeftYourMatch,
      rightLabel: AppText.oneHourAgo,
      subtitle: 'Slot available now',
    ),
  ];

  static final List<_NotificationItem> _yesterdayItems = [
    _NotificationItem(
      avatarLetter: 'H',
      title: AppText.yourFinalTournamentIsNowFull,
      rightLabel: AppText.yesterday,
      subtitle: '10 / 10 players joined',
    ),
    _NotificationItem(
      avatarLetter: 'R',
      title: AppText.alexStartedTheGame,
      rightLabel: AppText.yesterday,
      primaryActionText: AppText.viewMatch,
      isPrimaryActionFilled: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      body: MainFrame(
        child: ListView(
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
                SizedBox(width: context.w(28)),
              ],
            ),
            SizedBox(height: context.h(22)),
            NormalText(
              titleText: AppText.today,
              titleStyle: context.appText.text16W600,
            ),
            SizedBox(height: context.h(10)),
            ..._todayItems.map((n) => _NotificationCard(item: n)),
            SizedBox(height: context.h(8)),
            NormalText(
              titleText: AppText.yesterday,
              titleStyle: context.appText.text16W600,
            ),
            SizedBox(height: context.h(10)),
            ..._yesterdayItems.map((n) => _NotificationCard(item: n)),
            SizedBox(height: context.h(10)),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.avatarLetter,
    required this.title,
    required this.rightLabel,
    this.subtitle,
    this.showLocationIcon = false,
    this.primaryActionText,
    this.secondaryActionText,
    this.isPrimaryActionFilled = true,
  });

  final String avatarLetter;
  final String title;
  final String rightLabel;
  final String? subtitle;
  final bool showLocationIcon;
  final String? primaryActionText;
  final String? secondaryActionText;
  final bool isPrimaryActionFilled;
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final hasActions = item.primaryActionText != null;

    return CardWidget(
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
                        color: c.greyDark,
                      ),
                    ),
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
                  Row(
                    children: [
                      _ActionPill(
                        text: item.primaryActionText!,
                        filled: item.isPrimaryActionFilled,
                      ),
                      if (item.secondaryActionText != null) ...[
                        SizedBox(width: context.w(8)),
                        _ActionPill(
                          text: item.secondaryActionText!,
                          filled: false,
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
  const _ActionPill({required this.text, required this.filled});

  final String text;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
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
    );
  }
}
