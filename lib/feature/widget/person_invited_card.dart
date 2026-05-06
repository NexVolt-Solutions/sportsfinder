import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/match_card_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class PersonInvitedCard extends StatelessWidget {
  final String? playerName;
  final String? matchName;
  final String? matchLevel;
  final String? destance;
  final String? avatarUrl;
  final VoidCallback ontap;
  final VoidCallback? cardOnTap;
  final bool isShow;
  final bool isInvited;
  final bool isLoading;
  final bool isActionDisabled;

  const PersonInvitedCard({
    super.key,
    this.playerName,
    this.matchName,
    this.matchLevel,
    this.destance,
    this.avatarUrl,
    required this.ontap,
    this.isShow = false,
    this.cardOnTap,
    this.isInvited = false,
    this.isLoading = false,
    this.isActionDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      onTap: cardOnTap,
      padding: context.padAll(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                AppAvatar(
                  size: context.w(44),
                  imageUrl: avatarUrl,
                  fallbackText: playerName,
                  backgroundColor: context.appColors.primary,
                  iconColor: context.appColors.white,
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NormalText(
                        titleText: playerName ?? 'Shehzad Khan',
                        titleColor: context.appColors.onSurface,
                        maxLines: 1,
                      ),
                      NormalText(
                        titleText:
                            '${matchName ?? AppText.football} - ${matchLevel ?? AppText.advanced}',
                        titleColor: context.appColors.greylight,
                        titleStyle: context.appText.text14W500,
                        maxLines: 1,
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(AppAssets.homeLocIcon),
                          SizedBox(width: context.w(4)),
                          Expanded(
                            child: NormalText(
                              titleText: destance ?? AppText.filters,
                              titleColor: context.appColors.greylight,
                              titleStyle: context.appText.text14W500,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.w(8)),
          if (isShow)
            MatchCardButton(
              ontap: isInvited || isLoading || isActionDisabled ? null : ontap,
              isLoading: isLoading,
              text: isInvited ? 'Invited' : AppText.invite,
              color: isActionDisabled
                  ? context.appColors.greylight
                  : isInvited || isLoading
                  ? context.appColors.blue10
                  : context.appColors.surface,
              textColor: isActionDisabled
                  ? (context.appColors.white ?? Colors.white)
                  : isInvited || isLoading
                  ? context.appColors.greylight
                  : context.appColors.primary,
            ),
        ],
      ),
    );
  }
}
