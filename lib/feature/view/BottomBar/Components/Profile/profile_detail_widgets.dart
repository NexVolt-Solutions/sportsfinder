
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';

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

    Widget buildCard(
      Widget icon,
      String value,
      String label,
      VoidCallback? onTap,
    ) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: CardWidget(
            // padding: context.padSym(h: 12, v: 16),
            child: Column(
              children: [
                icon,

                SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: c.onSurface,
                  ),
                ),
                Text(label, style: TextStyle(fontSize: 11, color: c.greyDark)),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildCard(
          SvgPicture.asset(
            AppAssets.follow,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(c.greyDark, BlendMode.srcIn),
          ),
          "$followersCount",
          AppText.followers,
          onFollowersTap,
        ),
        SizedBox(width: 10),
        buildCard(
          SvgPicture.asset(
            AppAssets.follower,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(c.greyDark, BlendMode.srcIn),
          ),
          "$followingCount",
          AppText.following,
          onFollowingTap,
        ),
        SizedBox(width: 10),
        buildCard(
          Icon(Icons.star, color: c.greyDark, size: 18),
          ratingValue,
          AppText.rating,
          onRatingTap,
        ),
        SizedBox(width: 10),
        buildCard(
          Icon(Icons.sports_soccer_rounded, color: c.greyDark, size: 18),
          matchesPlayedValue,
          AppText.matches,
          onMatchesTap,
        ),
      ],
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
  });

  final String reviewAuthor;
  final String reviewDate;
  final String reviewBody;
  final String reviewInitial;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return CardWidget(
      padding: context.padSym(h: 14, v: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: c.blue10,
                child: Text(reviewInitial, style: TextStyle(color: c.primary)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewAuthor,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      reviewDate,
                      style: TextStyle(fontSize: 12, color: c.greyDark),
                    ),
                  ],
                ),
              ),
              Icon(Icons.star, color: Colors.amber),
            ],
          ),
          SizedBox(height: 10),
          Text(reviewBody),
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
  });

  final String sportName;
  final String skillLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return CardWidget(
      padding: context.padSym(h: 14, v: 12),
      child: Row(
        children: [
          Expanded(child: Text(sportName)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: c.primary),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(skillLabel, style: TextStyle(color: c.primary)),
          ),
        ],
      ),
    );
  }
}
