import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/Data/model/all_matches_model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/match_card_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/player_count_widget.dart';

/// Single match card used across Home, All Upcoming, and Discover screens.
/// Update the [build] method here to change match card appearance app-wide.
class GlobalMatchCard extends StatelessWidget {
  static bool _allMatchesHostedByCurrentUser(AllMatches match) {
    final myId = ProfileService().profile?.id;
    if (myId == null || myId.isEmpty) return false;
    return match.host.id.isNotEmpty && match.host.id == myId;
  }

  static double contentHeight(BuildContext context) =>
      kIsWeb ? context.h(220) : context.h(168);

   static double listSlotHeight(BuildContext context) =>
      kIsWeb ? context.h(256) : context.h(180);

 
  const GlobalMatchCard({
    super.key,
    required this.takenPlayer,
    required this.totalPlayer,
    this.hostName,
    this.matchName,
    this.loc,
    this.time,
    this.distance,
    this.playerNumer,
    this.isHostedByCurrentUser = false,
    this.showHostingBadge = true,
    this.showTrailingActions = true,
    this.cardOnTap,
    this.matchOnTap,
    this.navigationMatch,
  });

  /// Builds a [GlobalMatchCard] from an [AllMatches] model.
  /// Used in Home and All Upcoming screens.
  factory GlobalMatchCard.fromAllMatches(
    AllMatches match, {
    Key? key,
    VoidCallback? onCardTap,
    VoidCallback? onSeeAllTap,
    bool showHostingBadge = true,
    bool showTrailingActions = true,
  }) {
    return GlobalMatchCard(
      key: key,
      hostName: match.title,
      matchName: match.sport,
      loc: match.locationName,
      time: '${match.scheduledDate} ${match.scheduledTime}',
      distance: match.distanceKm,
      takenPlayer: match.currentPlayers,
      totalPlayer: match.maxPlayers,
      isHostedByCurrentUser: _allMatchesHostedByCurrentUser(match),
      showHostingBadge: showHostingBadge,
      showTrailingActions: showTrailingActions,
      cardOnTap: onCardTap,
      matchOnTap: onSeeAllTap,
    );
  }

  /// Builds a [GlobalMatchCard] from a [DiscoveryMatch] model.
  /// Used in the Discover screen.
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
      hostName: match.title,
      matchName: match.sportType,
      loc: match.location,
      time: match.time,
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

  // ────────────────────────────── Fields ─────────────────────────────────

  final String? hostName;
  final String? matchName;
  final String? loc;
  final String? time;
  final double? distance;

  /// Unused — kept for API compatibility. Use [takenPlayer] instead.
  final int? playerNumer;

  final int takenPlayer;
  final int totalPlayer;

  /// Whether the current user is hosting this match.
  final bool isHostedByCurrentUser;

  /// When false, the "You are hosting" chip is hidden even if [isHostedByCurrentUser] is true.
  final bool showHostingBadge;

  /// When false, the distance pill and "See all" button column are hidden.
  final bool showTrailingActions;

  final VoidCallback? cardOnTap;
  final VoidCallback? matchOnTap;
  final VoidCallback? navigationMatch;

  // ───────────────────────────────  UI  ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final primary = context.appColors.primary;
    final showHostingChip = isHostedByCurrentUser && showHostingBadge;

    final isCompactCard = !kIsWeb;
    final chipTopGap = isCompactCard ? 2.0 : 8.0;
    final sectionGap = isCompactCard ? 2.0 : 8.0;
    final metaGap = isCompactCard ? 2.0 : 8.0;

    return CardWidget(
      onTap: cardOnTap,
      padding: context.padSym(h: 16, v: isCompactCard ? 12 : 16),
      child: SizedBox(
        height: kIsWeb?260:180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NormalText(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  titleText: hostName,
                  titleColor: AppColors.blackcolor,
                  subText: matchName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showTrailingActions) ...[
                  MatchCardButton(
                    ontap: () {},
                    text: '${distance?.toStringAsFixed(1) ?? '0.0'} km',
                    color: context.appColors.surface,
                    textColor: AppColors.bluecolor,
                  ),
                ],
              ],
            ),
            if (showHostingChip) ...[
              SizedBox(height: chipTopGap),
              Align(
                alignment: Alignment.centerLeft,
                child: _HostingChip(primary: primary),
              ),
            ],
            SizedBox(height: sectionGap),
            _IconLabelRow(icon: AppAssets.homeLocIcon, label: loc),
            SizedBox(height: metaGap),
            _IconLabelRow(icon: AppAssets.homeTimeIcon, label: time),
            SizedBox(height: sectionGap),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PlayerCountWidget(
                  playerNo1: takenPlayer,
                  playerNo2: totalPlayer,
                ),
                if (showTrailingActions) ...[
                  MatchCardButton(
                    ontap: matchOnTap ?? () {},
                    text: AppText.seeAll,
                    color: context.appColors.primary,
                    textColor: AppColors.whitecolor,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

 
 class _HostingChip extends StatelessWidget {
  const _HostingChip({required this.primary, });

  final Color primary;
 
  @override
  Widget build(BuildContext context) {
    return Container(
    width: context.sw(115),
      padding: EdgeInsets.symmetric(
        horizontal: context.sw(4),
       ),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.radius(6)),
        border: Border.all(color: primary.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(Icons.verified_rounded, size: 15, color: primary),
          SizedBox(width: context.sw(4)),
          Expanded(
            child: Text(
              AppText.youAreHosting,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style:
                  context.appText.text12W600.copyWith(color: primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small SVG icon paired with a text label on the same row.
class _IconLabelRow extends StatelessWidget {
  const _IconLabelRow({required this.icon, required this.label});

  final String icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(icon),
        SizedBox(width: context.sw(8)),
        Expanded(
          child: NormalText(
            crossAxisAlignment: CrossAxisAlignment.start,
            titleText: label,
            titleStyle: context.appText.text12W600,
            titleColor: context.appColors.greylight,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
