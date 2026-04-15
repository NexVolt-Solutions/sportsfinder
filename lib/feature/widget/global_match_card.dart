import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/Data/model/all_matches_model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
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
  // ─────────────────────────── Sizing helpers ────────────────────────────

  /// Fixed inner content height so hosted/non-hosted cards stay aligned.
  static double contentHeight(BuildContext context) => context.sh(168);

  /// Total slot height: inner content + CardWidget margin (24) + vertical padding (36).
  static double listSlotHeight(BuildContext context) =>
      contentHeight(context) + 60;

  // ──────────────────────────── Constructors ─────────────────────────────

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
      isHostedByCurrentUser: false, // not provided by this API
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
    final innerH = contentHeight(context);

    return CardWidget(
      onTap: cardOnTap,
      padding: context.padSym(h: 16, v: 18),
      child: SizedBox(
        height: innerH,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Left column: match details ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + sport type
                  NormalText(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    titleText: hostName,
                    titleColor: AppColors.blackcolor,
                    subText: matchName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // "You are hosting" chip
                  if (showHostingChip) ...[
                    SizedBox(height: context.sh(6)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _HostingChip(primary: primary),
                    ),
                  ],

                  SizedBox(height: context.sh(8)),

                  // Location row
                  _IconLabelRow(icon: AppAssets.homeLocIcon, label: loc),

                  SizedBox(height: context.sh(4)),

                  // Time row
                  _IconLabelRow(icon: AppAssets.homeTimeIcon, label: time),

                  const Spacer(),

                  // Player count
                  PlayerCountWidget(
                    playerNo1: takenPlayer,
                    playerNo2: totalPlayer,
                  ),
                ],
              ),
            ),

            // ── Right column: distance + see all ──
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
                    textColor: AppColors.whitecolor,
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

// ──────────────────────────── Private widgets ──────────────────────────────

/// "You are hosting" badge shown on cards owned by the current user.
class _HostingChip extends StatelessWidget {
  const _HostingChip({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
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
