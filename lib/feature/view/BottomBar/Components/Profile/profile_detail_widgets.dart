// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:sport_finding/core/Constants/app_assets.dart';
// import 'package:sport_finding/core/Constants/app_text.dart';
// import 'package:sport_finding/core/Constants/app_theme.dart';
// import 'package:sport_finding/core/Constants/size_extension.dart';
// import 'package:sport_finding/feature/widget/card_widget.dart';
// import 'package:sport_finding/feature/widget/normal_text.dart';

// class ProfileDetailAvatar extends StatelessWidget {
//   const ProfileDetailAvatar({
//     super.key,
//     required this.url,
//     required this.size,
//     this.showTrophyBadge = false,
//   });

//   final String url;
//   final double size;
//   final bool showTrophyBadge;

//   @override
//   Widget build(BuildContext context) {
//     final c = context.appColors;
//     final avatar = ClipOval(
//       child: SizedBox(
//         width: size,
//         height: size,
//         child: Image.network(
//           url,
//           fit: BoxFit.cover,
//           cacheWidth: 300,
//           filterQuality: FilterQuality.medium,
//           loadingBuilder: (context, child, progress) {
//             if (progress == null) return child;
//             return ColoredBox(
//               color: c.blue10,
//               child: Center(
//                 child: SizedBox(
//                   width: context.w(28),
//                   height: context.w(28),
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: c.primary,
//                   ),
//                 ),
//               ),
//             );
//           },
//           errorBuilder: (context, error, _) => ColoredBox(
//             color: c.blue10,
//             child: Icon(
//               Icons.person_rounded,
//               size: context.w(40),
//               color: c.primary,
//             ),
//           ),
//         ),
//       ),
//     );

//     if (!showTrophyBadge) return avatar;

//     return Stack(
//       clipBehavior: Clip.none,
//       alignment: Alignment.center,
//       children: [
//         avatar,
//         Positioned(
//           right: -context.w(2),
//           bottom: -context.w(2),
//           child: Container(
//             width: context.w(28),
//             height: context.w(28),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.08),
//                   blurRadius: 4,
//                   offset: const Offset(0, 1),
//                 ),
//               ],
//             ),
//             child: Icon(
//               Icons.emoji_events_outlined,
//               size: context.w(16),
//               color: c.greylight,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class ProfileDetailHeader extends StatelessWidget {
//   const ProfileDetailHeader({
//     super.key,
//     required this.displayName,
//     required this.locationLabel,
//     required this.bio,
//     required this.avatarUrl,
//     required this.nameStyle,
//     required this.bioStyle,
//     required this.locationStyle,
//     this.showTrophyBadge = false,
//     this.avatarLogicalWidth = 96,
//   });

//   final String displayName;
//   final String locationLabel;
//   final String bio;
//   final String avatarUrl;
//   final TextStyle nameStyle;
//   final TextStyle bioStyle;
//   final TextStyle locationStyle;
//   final bool showTrophyBadge;
//   final double avatarLogicalWidth;

//   @override
//   Widget build(BuildContext context) {
//     final size = context.w(avatarLogicalWidth);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         ProfileDetailAvatar(
//           url: avatarUrl,
//           size: size,
//           showTrophyBadge: showTrophyBadge,
//         ),
//         SizedBox(height: context.h(14)),
//         NormalText(
//           titleText: displayName,
//           titleStyle: nameStyle,
//           titleAlign: TextAlign.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//         ),
//         SizedBox(height: context.h(8)),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SvgPicture.asset(AppAssets.iconOutline, width: 18, height: 18),
//             SizedBox(width: context.w(6)),
//             Flexible(
//               child: Text(
//                 locationLabel,
//                 style: locationStyle,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: context.h(12)),
//         Text(bio, style: bioStyle, textAlign: TextAlign.center),
//       ],
//     );
//   }
// }

// class ProfileDetailStatsRow extends StatelessWidget {
//   const ProfileDetailStatsRow({
//     super.key,
//     required this.followersCount,
//     required this.followingCount,
//     required this.ratingValue,
//     this.onFollowersTap,
//     this.onFollowingTap,
//   });

//   final int followersCount;
//   final int followingCount;
//   final String ratingValue;
//   final VoidCallback? onFollowersTap;
//   final VoidCallback? onFollowingTap;

//   @override
//   Widget build(BuildContext context) {
//     final c = context.appColors;
//     return Row(
//       children: [
//         Expanded(
//           child: CardWidget(
//             onTap: onFollowersTap,
//             padding: context.padSym(h: 12, v: 16),
//             child: _ProfileStatTile(
//               icon: SvgPicture.asset(
//                 AppAssets.follow,
//                 width: 22,
//                 height: 22,
//                 colorFilter: ColorFilter.mode(c.greyDark, BlendMode.srcIn),
//               ),
//               value: '$followersCount',
//               label: AppText.followers,
//             ),
//           ),
//         ),
//         SizedBox(width: context.w(12)),
//         Expanded(
//           child: CardWidget(
//             onTap: onFollowingTap,
//             padding: context.padSym(h: 12, v: 16),
//             child: _ProfileStatTile(
//               icon: SvgPicture.asset(AppAssets.follower, width: 22, height: 22),
//               value: '$followingCount',
//               label: AppText.following,
//             ),
//           ),
//         ),
//         SizedBox(width: context.w(12)),
//         Expanded(
//           child: CardWidget(
//             padding: context.padSym(h: 12, v: 16),
//             child: _ProfileStatTile(
//               icon: Icon(
//                 Icons.star_rounded,
//                 color: c.greyDark,
//                 size: context.w(22),
//               ),
//               value: ratingValue,
//               label: AppText.rating,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _ProfileStatTile extends StatelessWidget {
//   const _ProfileStatTile({
//     required this.icon,
//     required this.value,
//     required this.label,
//   });

//   final Widget icon;
//   final String value;
//   final String label;

//   @override
//   Widget build(BuildContext context) {
//     final c = context.appColors;
//     final t = context.appText;
//     return Column(
//       children: [
//         icon,
//         SizedBox(height: context.h(8)),
//         NormalText(
//           titleText: value,
//           titleStyle: t.text18Bold.copyWith(color: c.onSurface),
//           crossAxisAlignment: CrossAxisAlignment.center,
//         ),
//         NormalText(
//           subText: label,
//           subStyle: t.text12W400.copyWith(color: c.greyDark),
//           crossAxisAlignment: CrossAxisAlignment.center,
//           subAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
// }

// class ProfileDetailReviewCard extends StatelessWidget {
//   const ProfileDetailReviewCard({
//     super.key,
//     required this.reviewAuthor,
//     required this.reviewDate,
//     required this.reviewBody,
//     required this.reviewInitial,
//   });

//   final String reviewAuthor;
//   final String reviewDate;
//   final String reviewBody;
//   final String reviewInitial;

//   @override
//   Widget build(BuildContext context) {
//     final c = context.appColors;
//     final t = context.appText;
//     return CardWidget(
//       padding: context.padSym(h: 16, v: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CircleAvatar(
//                 radius: context.radius(22),
//                 backgroundColor: c.blue10,
//                 child: Text(
//                   reviewInitial,
//                   style: t.text16Bold.copyWith(color: c.primary),
//                 ),
//               ),
//               SizedBox(width: context.w(12)),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     NormalText(
//                       titleText: reviewAuthor,
//                       titleStyle: t.text14W600.copyWith(color: c.onSurface),
//                     ),
//                     NormalText(
//                       subText: reviewDate,
//                       subStyle: t.text12W400.copyWith(color: c.greylight),
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: List.generate(
//                   5,
//                   (_) => Padding(
//                     padding: EdgeInsets.only(left: context.w(2)),
//                     child: Icon(
//                       Icons.star_rounded,
//                       size: context.w(18),
//                       color: c.greylight,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: context.h(12)),
//           NormalText(
//             titleText: reviewBody,
//             titleStyle: t.text14W400.copyWith(color: c.onSurface, height: 1.45),
//             maxLines: 8,
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Sport row with outlined white skill pill (private profile design).
// class ProfilePrivateSportRow extends StatelessWidget {
//   const ProfilePrivateSportRow({
//     super.key,
//     required this.sportName,
//     required this.skillLabel,
//   });

//   final String sportName;
//   final String skillLabel;

//   @override
//   Widget build(BuildContext context) {
//     final c = context.appColors;
//     final t = context.appText;
//     return CardWidget(
//       padding: context.padSym(h: 14, v: 12),
//       child: Row(
//         children: [
//           Expanded(
//             child: NormalText(
//               titleText: sportName,
//               titleStyle: t.text14W500.copyWith(color: c.onSurface),
//               maxLines: 1,
//             ),
//           ),
//           SizedBox(width: context.w(8)),
//           Container(
//             padding: context.padSym(h: 12, v: 6),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(context.radius(20)),
//               border: Border.all(color: c.primary, width: 1),
//             ),
//             child: NormalText(
//               titleText: skillLabel,
//               titleStyle: t.text12W500.copyWith(color: c.primary),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
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
            color: c.greyDark,
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
            color: c.greyDark,
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
