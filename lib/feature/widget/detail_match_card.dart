import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view_model/player_count_widget.dart';
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
  final cardOnTap;
  final matchOnTap;
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
    this.isActive = false,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      onTap: cardOnTap,
      activeBorderColor: AppColors.bluecolor, // set the active color
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
          isActive
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MatchCardButton(
                      ontap: () {
                        print("Distance clicked");
                      },
                      text: "${distance?.toStringAsFixed(1) ?? 0} km",
                      color: context.appColors.surface,
                      textColor: AppColors.bluecolor,
                    ),
                    SizedBox(height: context.h(66)),
                    MatchCardButton(
                      ontap: matchOnTap,

                      text: AppText.seeAll,
                      color: context.appColors.primary,
                      textColor: context.appColors.onPrimary,
                    ),
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
