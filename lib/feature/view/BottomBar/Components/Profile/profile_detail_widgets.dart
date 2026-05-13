import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';

/// Five-star row: first [filledCount] stars filled (amber), remainder outlined.
class ProfileStarRatingRow extends StatelessWidget {
  const ProfileStarRatingRow({
    super.key,
    required this.filledCount,
    this.maxStars = 5,
    this.starSize = 16,
    this.spacing = 2,
  });

  final int filledCount;
  final int maxStars;
  final double starSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final n = filledCount.clamp(0, maxStars);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < maxStars; i++)
          Padding(
            padding: EdgeInsets.only(right: i < maxStars - 1 ? spacing : 0),
            child: Icon(
              i < n ? Icons.star_rounded : Icons.star_border_rounded,
              size: starSize,
              color: i < n ? const Color(0xFFFBBF24) : c.greylight,
            ),
          ),
      ],
    );
  }
}

/// ================= AVATAR =================
class ProfileDetailAvatar extends StatelessWidget {
  const ProfileDetailAvatar({
    super.key,
    required this.url,
    required this.size,
    this.showTrophyBadge = false,
  });

  final String url;
  final double size;
  final bool showTrophyBadge;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    final avatar = SizedBox(
      width: size,
      height: size,
      child: AppAvatar(size: size, imageUrl: url, backgroundColor: c.blue10),
    );

    if (!showTrophyBadge) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              size: 16,
              color: c.greyDark,
            ),
          ),
        ),
      ],
    );
  }
}

/// ================= HEADER =================
class ProfileDetailHeader extends StatelessWidget {
  const ProfileDetailHeader({
    super.key,
    required this.displayName,
    required this.locationLabel,
    required this.bio,
    required this.avatarUrl,
    required this.nameStyle,
    required this.bioStyle,
    required this.locationStyle,
    this.showTrophyBadge = false,
    this.avatarSize = 96,
  });

  final String displayName;
  final String locationLabel;
  final String bio;
  final String avatarUrl;

  final TextStyle nameStyle;
  final TextStyle bioStyle;
  final TextStyle locationStyle;

  final bool showTrophyBadge;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileDetailAvatar(
          url: avatarUrl,
          size: context.w(avatarSize),
          showTrophyBadge: showTrophyBadge,
        ),
        SizedBox(height: context.h(12)),

        Text(displayName, style: nameStyle, textAlign: TextAlign.center),

        SizedBox(height: context.h(6)),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: context.appColors.greyDark,
            ),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                locationLabel,
                style: locationStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        SizedBox(height: context.h(10)),

        Text(bio, style: bioStyle, textAlign: TextAlign.center),
      ],
    );
  }
}

/// ================= STATS =================
class ProfileDetailStatsRow extends StatelessWidget {
  const ProfileDetailStatsRow({
    super.key,
    required this.followersCount,
    required this.followingCount,
    required this.ratingValue,
    required this.matchesPlayedValue,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onRatingTap,
    this.onMatchesTap,
  });

  final int followersCount;
  final int followingCount;
  final String ratingValue;
  final String matchesPlayedValue;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onRatingTap;
  final VoidCallback? onMatchesTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final rowW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final gap = rowW < 320
            ? 4.0
            : rowW < 360
            ? 6.0
            : 10.0;
        final slotW = (rowW - 3 * gap) / 4;
        final iconSize = math.min(18.0, math.max(14.0, slotW * 0.28));
        final valueSize = math.min(14.0, math.max(10.0, slotW * 0.22));
        final labelSize = math.min(11.0, math.max(8.5, slotW * 0.18));
        final padH = slotW < 52 ? 4.0 : (slotW < 64 ? 6.0 : 8.0);

        Widget buildCard(
          Widget icon,
          String value,
          String label,
          VoidCallback? onTap,
        ) {
          return Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: onTap,
              child: CardWidget(
                padding: EdgeInsets.symmetric(horizontal: padH, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: SizedBox(
                        width: iconSize,
                        height: iconSize,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: icon,
                        ),
                      ),
                    ),
                    SizedBox(height: math.min(8.0, slotW * 0.12)),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: valueSize,
                        fontWeight: FontWeight.bold,
                        color: c.onSurface,
                        height: 1.15,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: math.min(4.0, slotW * 0.06)),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: labelSize,
                        color: c.greyDark,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // [ListView] gives this row unbounded max height; [CrossAxisAlignment.stretch]
        // is invalid there and triggers a layout assert.
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCard(
              SvgPicture.asset(
                AppAssets.follow,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(c.greyDark, BlendMode.srcIn),
              ),
              '$followersCount',
              AppText.followers,
              onFollowersTap,
            ),
            SizedBox(width: gap),
            buildCard(
              SvgPicture.asset(
                AppAssets.follower,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(c.greyDark, BlendMode.srcIn),
              ),
              '$followingCount',
              AppText.following,
              onFollowingTap,
            ),
            SizedBox(width: gap),
            buildCard(
              Icon(Icons.star, color: c.greyDark, size: 18),
              ratingValue,
              AppText.rating,
              onRatingTap,
            ),
            SizedBox(width: gap),
            buildCard(
              Icon(Icons.sports_soccer_rounded, color: c.greyDark, size: 18),
              matchesPlayedValue,
              AppText.matches,
              onMatchesTap,
            ),
          ],
        );
      },
    );
  }
}

/// ================= REVIEW =================
class ProfileDetailReviewCard extends StatelessWidget {
  const ProfileDetailReviewCard({
    super.key,
    required this.reviewAuthor,
    required this.reviewDate,
    required this.reviewBody,
    required this.reviewInitial,
    this.reviewRatingStars = 0,
  });

  final String reviewAuthor;
  final String reviewDate;
  final String reviewBody;
  final String reviewInitial;
  final int reviewRatingStars;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    final stars = reviewRatingStars.clamp(0, 5);

    return CardWidget(
      padding: context.padSym(h: 14, v: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: c.blue10,
                child: Text(
                  reviewInitial,
                  style: TextStyle(
                    color: c.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: context.w(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewAuthor,
                      style: t.text16W500.copyWith(
                        fontWeight: FontWeight.w600,
                        color: c.greyDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.h(4)),
                    Row(
                      children: [
                        ProfileStarRatingRow(filledCount: stars),
                        const Spacer(),
                        Text(
                          reviewDate,
                          style: t.text12W400.copyWith(color: c.greylight),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(10)),
          Text(
            reviewBody,
            style: t.text14W400.copyWith(color: c.greyDark, height: 1.45),
          ),
        ],
      ),
    );
  }
}

/// ================= SPORT ROW =================
class ProfilePrivateSportRow extends StatelessWidget {
  const ProfilePrivateSportRow({
    super.key,
    required this.sportName,
    required this.skillLabel,
    this.categoryLabel = '',
  });

  final String sportName;
  final String skillLabel;
  final String categoryLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    final cat = categoryLabel.trim();

    return CardWidget(
      padding: context.padSym(h: 14, v: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sportName,
                  style: t.text16W500.copyWith(color: c.greyDark),
                ),
                if (cat.isNotEmpty) ...[
                  SizedBox(height: context.h(4)),
                  Text(
                    cat,
                    style: t.text12W400.copyWith(color: c.greylight),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: context.w(8)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: c.primary),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              skillLabel,
              style: t.text14W500.copyWith(color: c.primary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
