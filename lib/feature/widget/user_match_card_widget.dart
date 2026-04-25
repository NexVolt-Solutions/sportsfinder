import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class UserMatchCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final String? avatarUrl;
  final bool showActionIcon;
  final VoidCallback? onActionTap; // 👈 new callback
  final VoidCallback? onCardTap; // 👈 new callback

  const UserMatchCard({
    super.key,
    required this.title,
    required this.subTitle,
    this.avatarUrl,
    this.showActionIcon = false,
    this.onActionTap,
    this.onCardTap, // 👈 receive from parent
  });

  String getInitials(String text) {
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
      onTap: onCardTap,
      padding: context.padSym(h: 12, v: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: context.radiusR(22),
                  backgroundColor: context.appColors.greyDark,
                  backgroundImage:
                      showAvatar ? NetworkImage(normalizedAvatarUrl) : null,
                  child: showAvatar
                      ? null
                      : Text(
                          getInitials(title),
                          style: TextStyle(
                            color: context.appColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

          /// ✅ Show/Hide SVG with onTap
          if (showActionIcon)
            GestureDetector(
              onTap: onActionTap, // 👈 trigger the callback
              child: SvgPicture.asset(AppAssets.removeUserIcon),
            ),
        ],
      ),
    );
  }
}
