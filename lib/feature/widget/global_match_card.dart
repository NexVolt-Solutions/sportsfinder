import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/discovery_match_navigation.dart';
import 'package:sport_finding/feature/model/discovery_match.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/match_card_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/player_count_widget.dart';

/// Single match row/card used across Home, All Upcoming, Discover, etc.
/// Change this widget to update match list appearance app-wide.
class GlobalMatchCard extends StatelessWidget {
  /// Fixed inner row height (scaled) so hosted / non-hosted cards align everywhere.
  static double contentHeight(BuildContext context) => context.sh(180);

  /// CardWidget margin (24) + vertical padding (36) + [contentHeight].
  static double listSlotHeight(BuildContext context) =>
      contentHeight(context) + 60;

  const GlobalMatchCard({
    super.key,
    required this.takenPlayer,
    required this.totalPlayer,
    this.hostName,
    this.matchName,
    this.loc,
    this.time,
    this.playerNumer,
    this.cardOnTap,
    this.matchOnTap,
    this.navigationMatch,
    this.isActive = false,
    this.distance,
    this.isHostedByCurrentUser = false,
    this.showHostingBadge = true,
    this.showTrailingActions = true,
  });

  /// Builds from [DiscoveryMatch] with the same layout as manual fields.
  factory GlobalMatchCard.fromDiscovery(
    DiscoveryMatch match, {
    Key? key,
    VoidCallback? onCardTap,
    VoidCallback? onSeeAllTap,
    bool showHostingBadge = true,
    bool showTrailingActions = true,
  }) {
    return GlobalMatchCard(
      key: key,
      navigationMatch: match,
      hostName: match.title,
      matchName: match.sportType,
      loc: match.location,
      time: match.date,
      distance: match.distanceKm,
      takenPlayer: match.participantsJoined,
      totalPlayer: match.participantsTotal,
      isHostedByCurrentUser: match.isHostedByCurrentUser,
      showHostingBadge: showHostingBadge,
      showTrailingActions: showTrailingActions,
      cardOnTap: onCardTap,
      matchOnTap: onSeeAllTap,
    );
  }

  final String? hostName;
  final String? matchName;
  final String? loc;
  final String? time;
  final double? distance;
  final int? playerNumer;
  final int takenPlayer;
  final int totalPlayer;
  final bool isActive;
  final bool isHostedByCurrentUser;

  /// When false, hosting chip and primary border emphasis are hidden.
  final bool showHostingBadge;
  final VoidCallback? cardOnTap;
  final VoidCallback? matchOnTap;
  final DiscoveryMatch? navigationMatch;

  /// Distance + “See all” column (list rows usually want this on).
  final bool showTrailingActions;

  @override
  Widget build(BuildContext context) {
    final primary = context.appColors.primary;
    final hostingEmphasis = isHostedByCurrentUser && showHostingBadge;
    final innerH = contentHeight(context);

    Widget hostingChip() => Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sw(8),
        vertical: context.sh(4),
      ),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.radiusR(6)),
        border: Border.all(color: primary.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 15, color: primary),
          SizedBox(width: context.sw(4)),
          Text(
            AppText.youAreHosting,
            style: context.appText.text12W600.copyWith(color: primary),
          ),
        ],
      ),
    );

    return CardWidget(
      onTap:
          cardOnTap ??
          (navigationMatch != null
              ? () => navigationMatch!.pushMatchOrHostScreen(context)
              : null),
      activeBorderColor: hostingEmphasis ? primary : AppColors.bluecolor,
      borderColor: hostingEmphasis ? primary.withValues(alpha: 0.45) : null,
      isActive: isActive || hostingEmphasis,
      padding: context.padSym(h: 16, v: 18),
      child: SizedBox(
        height: innerH,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NormalText(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    titleText: hostName,
                    titleColor: AppColors.blackcolor,
                    subText: matchName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hostingEmphasis) ...[
                    SizedBox(height: context.sh(6)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: hostingChip(),
                    ),
                  ],
                  SizedBox(height: context.sh(8)),
                  Row(
                    children: [
                      SvgPicture.asset(AppAssets.homeLocIcon),
                      SizedBox(width: context.sw(8)),
                      Expanded(
                        child: NormalText(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          titleText: loc,
                          titleStyle: context.appText.text12W600,
                          titleColor: context.appColors.greylight,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.sh(4)),
                  Row(
                    children: [
                      SvgPicture.asset(AppAssets.homeTimeIcon),
                      SizedBox(width: context.sw(8)),
                      Expanded(
                        child: NormalText(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          titleText: time,
                          titleStyle: context.appText.text12W600,
                          titleColor: context.appColors.greylight,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  PlayerCountWidget(
                    playerNo1: takenPlayer,
                    playerNo2: totalPlayer,
                  ),
                ],
              ),
            ),
            if (showTrailingActions) ...[
              SizedBox(width: context.sw(12)),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MatchCardButton(
                    ontap: () {},
                    text: '${distance?.toStringAsFixed(1) ?? '0.0'} km',
                    color: context.appColors.surface,
                    textColor: AppColors.bluecolor,
                  ),
                  MatchCardButton(
                    ontap: matchOnTap ?? () {},
                    text: AppText.seeAll,
                    color: context.appColors.primary,
                    textColor: context.appColors.onPrimary,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
