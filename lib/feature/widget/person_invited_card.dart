import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/match_card_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class PersonInvitedCard extends StatelessWidget {
  final String? playerName;
  final String? matchName;
  final String? matchLevel;
  final String? destance;
  final ontap;
  final VoidCallback? cardOnTap; // whole card tap
  final bool isShow;

  const PersonInvitedCard({
    super.key,
    this.playerName,
    this.matchName,
    this.matchLevel,
    this.destance,
    this.ontap,
    this.isShow = false,
    this.cardOnTap,
  });

  // function to get initials from player name
  String getInitials(String? text) {
    if (text == null || text.isEmpty) return "";
    return text.length >= 2
        ? text.substring(0, 2).toUpperCase()
        : text.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      onTap: cardOnTap,
      padding: context.padAll(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // ✅ CircleAvatar like UserMatchCard
              CircleAvatar(
                radius: context.radiusR(22), // half of previous 42 height
                backgroundColor: context.appColors.primary,
                child: Text(
                  getInitials(playerName),
                  style: TextStyle(
                    color: context.appColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: context.w(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NormalText(
                    titleText: playerName ?? 'Shehzad Khan',
                    titleColor: context.appColors.onSurface,
                  ),
                  Row(
                    children: [
                      NormalText(
                        titleText: matchName ?? AppText.football,
                        titleColor: context.appColors.greylight,
                        titleStyle: context.appText.text14W500,
                      ),
                      SizedBox(width: context.w(12)),
                      NormalText(
                        titleText: matchLevel ?? AppText.advanced,
                        titleColor: context.appColors.greylight,
                        titleStyle: context.appText.text14W500,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(AppAssets.homeLocIcon),
                      SizedBox(width: context.w(4)),
                      NormalText(
                        titleText: destance ?? AppText.filters,
                        titleColor: context.appColors.greylight,
                        titleStyle: context.appText.text14W500,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (isShow)
            MatchCardButton(
              ontap: ontap,
              text: AppText.invite,
              color: context.appColors.surface,
              textColor: context.appColors.primary,
            ),
        ],
      ),
    );
  }
}
