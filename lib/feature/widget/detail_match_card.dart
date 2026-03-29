import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/discovery_match_navigation.dart';
import 'package:sport_finding/feature/model/discovery_match.dart';
import 'package:sport_finding/feature/widget/player_count_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/match_card_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class DetailsMatchesCard extends StatelessWidget {
  final String? hostName;
  final String? matchName;
  final String? loc;
  final String? time;
  final double? distance;
  final int? playerNumer;
  final int? takenPlayer;
  final int? totalPlayer;
  final bool isActive;
  final bool isHostedByCurrentUser;

  /// When false, hosting chip and primary border are hidden (e.g. **My Matches** is host-only).
  final bool showHostingBadge;
  final VoidCallback? cardOnTap;
  final VoidCallback? matchOnTap;

  /// When set and [cardOnTap] is null, card tap uses [pushMatchOrHostScreen].
  final DiscoveryMatch? navigationMatch;
  const DetailsMatchesCard({
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
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.appColors.primary;
    final hostingEmphasis = isHostedByCurrentUser && showHostingBadge;
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NormalText(
                crossAxisAlignment: CrossAxisAlignment.start,
                titleText: hostName,
                titleColor: AppColors.blackcolor,
                subText: matchName,
              ),
              if (hostingEmphasis) ...[
                SizedBox(height: context.h(6)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(8),
                    vertical: context.h(4),
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
                      SizedBox(width: context.w(4)),
                      Text(
                        AppText.youAreHosting,
                        style: context.appText.text12W600.copyWith(
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: context.h(8)),
              Row(
                children: [
                  SvgPicture.asset(AppAssets.homeLocIcon),
                  SizedBox(width: context.w(8)),
                  NormalText(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    titleText: loc,
                    titleStyle: context.appText.text12W600,
                    titleColor: context.appColors.greylight,
                  ),
                ],
              ),
              SizedBox(height: context.h(4)),
              Row(
                children: [
                  SvgPicture.asset(AppAssets.homeTimeIcon),
                  SizedBox(width: context.w(8)),
                  NormalText(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    titleText: time,
                    titleStyle: context.appText.text12W600,
                    titleColor: context.appColors.greylight,
                  ),
                ],
              ),
              SizedBox(height: context.h(8)),
              PlayerCountWidget(
                playerNo1: takenPlayer ?? 0,
                playerNo2: totalPlayer ?? 0,
              ),
            ],
          ),
          (isActive || hostingEmphasis)
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MatchCardButton(
                      ontap: () {},
                      text: "${distance?.toStringAsFixed(1) ?? 0} km",
                      color: context.appColors.surface,
                      textColor: AppColors.bluecolor,
                    ),
                    SizedBox(height: context.h(66)),
                    MatchCardButton(
                      ontap: matchOnTap ?? () {},
                      text: AppText.seeAll,
                      color: context.appColors.primary,
                      textColor: context.appColors.onPrimary,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
