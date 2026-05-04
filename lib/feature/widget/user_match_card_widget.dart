import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class UserMatchCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final String? avatarUrl;
  final bool showActionIcon;
  final VoidCallback? onActionTap;
  final VoidCallback? onCardTap;

  const UserMatchCard({
    super.key,
    required this.title,
    required this.subTitle,
    this.avatarUrl,
    this.showActionIcon = false,
    this.onActionTap,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      onTap: onCardTap,
      padding: context.padSym(h: 12, v: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                AppAvatar(
                  size: context.w(44),
                  imageUrl: avatarUrl,
                  fallbackText: title,
                  backgroundColor: context.appColors.greyDark,
                  iconColor: context.appColors.white,
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: NormalText(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    titleText: title,
                    subText: subTitle,
                    subAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (showActionIcon)
            GestureDetector(
              onTap: onActionTap,
              child: SvgPicture.asset(AppAssets.removeUserIcon),
            ),
        ],
      ),
    );
  }
}
