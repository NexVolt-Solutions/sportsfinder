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
  final cardOnTap;
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
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.appColors.primary,
                ),
              ),
              SizedBox(width: context.w(12)),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NormalText(
                        titleText: playerName ?? 'Shehzad khan',
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
