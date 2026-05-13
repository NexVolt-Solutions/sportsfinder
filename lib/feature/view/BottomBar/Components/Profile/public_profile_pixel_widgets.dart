import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

/// Design reference: public profile mock — light grey page, white / blue-10 cards,
/// primary CTA + square follow, stats without icons, About card, sports rows, reviews.
class PublicProfilePixelTheme {
  const PublicProfilePixelTheme._();

  static const Color pageBackground = Color(0xFFF2F4F7);
  static const double cardRadius = 14;
  static List<BoxShadow> cardShadow(BuildContext context) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ];
}

class PublicProfileBackPill extends StatelessWidget {
  const PublicProfileBackPill({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            AppText.publicProfileBack,
            style: t.text14W500.copyWith(color: c.greyDark),
          ),
        ),
      ),
    );
  }
}

class PublicProfileHeroCard extends StatelessWidget {
  const PublicProfileHeroCard({
    super.key,
    required this.displayName,
    required this.location,
    required this.avatarUrl,
    required this.isOwnProfile,
    this.onMessage,
    this.onFollow,
    this.onEditProfile,
    this.isFollowing = false,
    this.isFollowLoading = false,
  });

  final String displayName;
  final String location;
  final String avatarUrl;
  final bool isOwnProfile;
  final VoidCallback? onMessage;
  final Future<void> Function()? onFollow;
  final VoidCallback? onEditProfile;
  final bool isFollowing;
  final bool isFollowLoading;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    return Container(
      width: double.infinity,
      padding: context.padSym(h: 20, v: 22),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(PublicProfilePixelTheme.cardRadius),
        boxShadow: PublicProfilePixelTheme.cardShadow(context),
      ),
      child: Column(
        children: [
          _AvatarWithTrophy(
            url: avatarUrl,
            name: displayName,
            size: context.w(112),
          ),
          SizedBox(height: context.h(16)),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: t.style(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: c.greyDark,
              height: 1.2,
            ),
          ),
          SizedBox(height: context.h(6)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: c.greylight),
              SizedBox(width: context.w(4)),
              Flexible(
                child: Text(
                  location,
                  textAlign: TextAlign.center,
                  style: t.text14W400.copyWith(color: c.greylight, height: 1.3),
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(20)),
          
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: AppText.message,
                    onTap: onMessage,
                    color: c.primary,
                    colorText: c.onPrimary,
                    radius: BorderRadius.circular(12),
                    padding: context.padSym(h: 16, v: 14),
                  ),
                ),
                SizedBox(width: context.w(10)),
                Material(
                  color: c.blue10,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: isFollowLoading || onFollow == null
                        ? null
                        : () => onFollow!(),
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: context.w(52),
                      height: context.w(52),
                      child: Center(
                        child: isFollowLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: c.primary,
                                ),
                              )
                            : Icon(
                                isFollowing
                                    ? Icons.person_remove_alt_1_outlined
                                    : Icons.person_add_alt_1_rounded,
                                color: c.primary,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AvatarWithTrophy extends StatelessWidget {
  const _AvatarWithTrophy({
    required this.url,
    required this.name,
    required this.size,
  });

  final String url;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        AppAvatar(
          size: size,
          imageUrl: url,
          fallbackText: name,
          backgroundColor: c.blue10,
          iconColor: c.primary,
        ),
        Positioned(
          right: context.w(4),
          bottom: context.w(2),
          child: Container(
            width: 28,
            height: 28,
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

class PublicProfileStatsRowPixel extends StatelessWidget {
  const PublicProfileStatsRowPixel({
    super.key,
    required this.followers,
    required this.following,
    required this.rating,
    required this.matches,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onRatingTap,
    this.onMatchesTap,
  });

  final String followers;
  final String following;
  final String rating;
  final String matches;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onRatingTap;
  final VoidCallback? onMatchesTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    return LayoutBuilder(
      builder: (context, constraints) {
        final rowW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final gap = rowW < 360 ? 8.0 : 12.0;
        Widget cell(String value, String label, VoidCallback? onTap) {
          return Expanded(
            child: Material(
              color: c.blue10,
              borderRadius: BorderRadius.circular(
                PublicProfilePixelTheme.cardRadius,
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(
                  PublicProfilePixelTheme.cardRadius,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.h(14),
                    horizontal: 6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.style(
                          fontSize: rowW < 340 ? 18 : 22,
                          fontWeight: FontWeight.w700,
                          color: c.onSurface,
                        ),
                      ),
                      SizedBox(height: context.h(6)),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: t.text12W400.copyWith(
                          color: c.greyDark,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cell(followers, AppText.followers, onFollowersTap),
            SizedBox(width: gap),
            cell(following, AppText.following, onFollowingTap),
            SizedBox(width: gap),
            cell(rating, AppText.rating, onRatingTap),
            SizedBox(width: gap),
            cell(matches, AppText.matchesPlayed, onMatchesTap),
          ],
        );
      },
    );
  }
}

class PublicProfileAboutCard extends StatelessWidget {
  const PublicProfileAboutCard({super.key, required this.bio});

  final String bio;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    return Container(
      width: double.infinity,
      padding: context.padAll(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(PublicProfilePixelTheme.cardRadius),
        boxShadow: PublicProfilePixelTheme.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppText.publicProfileAbout,
            style: t.text18Bold.copyWith(color: c.greyDark),
          ),
          SizedBox(height: context.h(12)),
          Text(
            bio,
            style: t.text16W400.copyWith(
              fontSize: 15,
              color: c.greylight,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class PublicProfileMySportsHeader extends StatelessWidget {
  const PublicProfileMySportsHeader({super.key, this.onAllSportsTap});

  final VoidCallback? onAllSportsTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(12)),
      child: Row(
        children: [
          Text(
            AppText.mySports,
            style: t.text16Bold.copyWith(color: c.greyDark),
          ),
          const Spacer(),
          if (onAllSportsTap != null)
            InkWell(
              onTap: onAllSportsTap,
              child: Text(
                AppText.allSportsLink,
                style: t.text14W500.copyWith(color: c.primary),
              ),
            ),
        ],
      ),
    );
  }
}

class PublicProfileSportRowPixel extends StatelessWidget {
  const PublicProfileSportRowPixel({
    super.key,
    required this.sportName,
    required this.skillLabel,
  });

  final String sportName;
  final String skillLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(10)),
      child: Container(
        width: double.infinity,
        padding: context.padSym(h: 16, v: 14),
        decoration: BoxDecoration(
          color: c.blue10,
          borderRadius: BorderRadius.circular(
            PublicProfilePixelTheme.cardRadius,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                sportName,
                style: t.text16W500.copyWith(fontSize: 15, color: c.greyDark),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                skillLabel,
                style: t.text14W500.copyWith(fontSize: 13, color: c.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PublicProfileReviewCardPixel extends StatelessWidget {
  const PublicProfileReviewCardPixel({
    super.key,
    required this.author,
    required this.dateLabel,
    required this.body,
    required this.initial,
  });

  final String author;
  final String dateLabel;
  final String body;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    final starColor = const Color(0xFF6B7280);
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(12)),
      child: Container(
        width: double.infinity,
        padding: context.padSym(h: 16, v: 14),
        decoration: BoxDecoration(
          color: c.blue10,
          borderRadius: BorderRadius.circular(
            PublicProfilePixelTheme.cardRadius,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: c.surface,
                  child: Text(
                    initial.isNotEmpty ? initial[0].toUpperCase() : '?',
                    style: t.text16Bold.copyWith(color: c.primary),
                  ),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author,
                        style: t.text16W600.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: c.greyDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: context.h(4)),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: starColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            dateLabel,
                            style: t.text12W400.copyWith(color: c.greylight),
                          ),
                        ],
                      ),
                      SizedBox(height: context.h(8)),
                      Text(
                        body,
                        style: t.text14W400.copyWith(
                          color: c.greyDark,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PublicProfileRateBar extends StatelessWidget {
  const PublicProfileRateBar({super.key, required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return CustomButton(
      text: AppText.ratePlayer,
      color: c.primary,
      radius: BorderRadius.circular(12),
      padding: context.padSym(h: 16, v: 12),
      colorText: c.onPrimary,
      onTap: onTap,
      leading: Icon(Icons.star_rounded, color: c.onPrimary, size: 22),
    );
  }
}

/// Scrollable pixel layout for public profile (mobile + web).
class PublicProfilePixelScaffold extends StatelessWidget {
  const PublicProfilePixelScaffold({
    super.key,
    required this.onBack,
    required this.displayName,
    required this.location,
    required this.bio,
    required this.avatarUrl,
    required this.followers,
    required this.following,
    required this.rating,
    required this.matches,
    required this.sports,
    required this.reviews,
    required this.isOwnProfile,
    this.onMessage,
    this.onFollow,
    this.onEditProfile,
    this.isFollowing = false,
    this.isFollowLoading = false,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onRatingTap,
    this.onMatchesTap,
    this.onRatePlayer,
    this.showRateButton = true,
    this.onAllSportsTap,
    this.wideBreakpoint = 960,
  });

  final VoidCallback onBack;
  final String displayName;
  final String location;
  final String bio;
  final String avatarUrl;
  final String followers;
  final String following;
  final String rating;
  final String matches;
  final List<({String name, String skill})> sports;
  final List<({String author, String date, String body, String initial})>
  reviews;
  final bool isOwnProfile;
  final VoidCallback? onMessage;
  final Future<void> Function()? onFollow;
  final VoidCallback? onEditProfile;
  final bool isFollowing;
  final bool isFollowLoading;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onRatingTap;
  final VoidCallback? onMatchesTap;
  final VoidCallback? onRatePlayer;
  final bool showRateButton;
  final VoidCallback? onAllSportsTap;
  final double wideBreakpoint;

  @override
  Widget build(BuildContext context) {
    final horizontal = context.w(20);
    final bottom = context.h(28);
    return SafeArea(
      child: ColoredBox(
        color: PublicProfilePixelTheme.pageBackground,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= wideBreakpoint;
            final hero = PublicProfileHeroCard(
              displayName: displayName,
              location: location,
              avatarUrl: avatarUrl,
              isOwnProfile: isOwnProfile,
              onMessage: onMessage,
              onFollow: onFollow,
              onEditProfile: onEditProfile,
              isFollowing: isFollowing,
              isFollowLoading: isFollowLoading,
            );
            final stats = PublicProfileStatsRowPixel(
              followers: followers,
              following: following,
              rating: rating,
              matches: matches,
              onFollowersTap: onFollowersTap,
              onFollowingTap: onFollowingTap,
              onRatingTap: onRatingTap,
              onMatchesTap: onMatchesTap,
            );
            final about = PublicProfileAboutCard(bio: bio);
            final rate = showRateButton
                ? PublicProfileRateBar(onTap: onRatePlayer)
                : const SizedBox.shrink();
            final sportsBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PublicProfileMySportsHeader(onAllSportsTap: onAllSportsTap),
                ...sports.map(
                  (s) => PublicProfileSportRowPixel(
                    sportName: s.name,
                    skillLabel: s.skill,
                  ),
                ),
              ],
            );
            final reviewsBlock = reviews.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: context.h(8),
                          bottom: context.h(12),
                        ),
                        child: NormalText(
                          titleText: AppText.reviews,
                          titleStyle: context.appText.text16Bold.copyWith(
                            color: context.appColors.greyDark,
                          ),
                        ),
                      ),
                      ...reviews.map(
                        (r) => PublicProfileReviewCardPixel(
                          author: r.author,
                          dateLabel: r.date,
                          body: r.body,
                          initial: r.initial,
                        ),
                      ),
                    ],
                  );

            final back = PublicProfileBackPill(onTap: onBack);

            if (wide) {
              final sideW = 320.0;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  context.h(16),
                  horizontal,
                  bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    back,
                    SizedBox(height: context.h(16)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: sideW, child: hero),
                        SizedBox(width: context.w(24)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              stats,
                              SizedBox(height: context.h(18)),
                              about,
                              if (showRateButton) ...[
                                SizedBox(height: context.h(14)),
                                rate,
                              ],
                              SizedBox(height: context.h(20)),
                              sportsBlock,
                              reviewsBlock,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                context.h(12),
                horizontal,
                bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  back,
                  SizedBox(height: context.h(16)),
                  hero,
                  SizedBox(height: context.h(18)),
                  stats,
                  SizedBox(height: context.h(18)),
                  about,
                  if (showRateButton) ...[
                    SizedBox(height: context.h(14)),
                    rate,
                  ],
                  SizedBox(height: context.h(20)),
                  sportsBlock,
                  reviewsBlock,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
