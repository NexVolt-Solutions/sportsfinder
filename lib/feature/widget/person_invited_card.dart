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
  final String? avatarUrl;
  final VoidCallback ontap;
  final VoidCallback? cardOnTap; // whole card tap
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

  // function to get initials from player name
  String getInitials(String? text) {
    if (text == null || text.isEmpty) return "";
    return text.length >= 2
        ? text.substring(0, 2).toUpperCase()
        : text.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedAvatarUrl = avatarUrl?.trim();
    final showAvatar =
        normalizedAvatarUrl != null &&
        (normalizedAvatarUrl.startsWith('http://') ||
            normalizedAvatarUrl.startsWith('https://'));
    return CardWidget(
      onTap: cardOnTap,
      padding: context.padAll(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // ✅ CircleAvatar like UserMatchCard
                CircleAvatar(
                  radius: context.radiusR(22), // half of previous 42 height
                  backgroundColor: context.appColors.primary,
                  child: showAvatar
                      ? ClipOval(
                          child: Image.network(
                            normalizedAvatarUrl,
                            width: context.w(44),
                            height: context.w(44),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Text(
                              getInitials(playerName),
                              style: TextStyle(
                                color: context.appColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          getInitials(playerName),
                          style: TextStyle(
                            color: context.appColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                        mainAxisAlignment: MainAxisAlignment.start,
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
              text: isLoading
                  ? 'Inviting...'
                  : isInvited
                  ? 'Invited'
                  : AppText.invite,
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
