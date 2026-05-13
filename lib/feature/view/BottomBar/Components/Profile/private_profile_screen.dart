import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/public_profile_args.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/profile_detail_widgets.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/public_profile_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/shimmer_loading.dart';

class PrivateProfileScreen extends StatelessWidget {
  const PrivateProfileScreen({super.key, this.onEmbeddedClose});

  /// Web profile split shell: back closes the pane instead of [Navigator.pop].
  final VoidCallback? onEmbeddedClose;

  void _popOrClose(BuildContext context) {
    final c = onEmbeddedClose;
    if (c != null) {
      c();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PublicProfileViewModel(
        args: PublicProfileArgs.privateProfilePreview(),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer<PublicProfileViewModel>(
          builder: (context, model, _) {
            final c = context.appColors;
            final t = context.appText;

            return MainFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: context.padSym(h: 20),
                    child: AppBarWidget(
                      title: AppText.privateProfile,
                      onLeadingTap: () => _popOrClose(context),
                    ),
                  ),
                  Expanded(
                    child: model.showSpinner
                        ? const _PrivateProfileShimmer()
                        : model.showError
                            ? Padding(
                                padding: context.padSym(h: 20),
                                child: Center(
                                  child: Text(
                                    model.displayError,
                                    textAlign: TextAlign.center,
                                    style: t.text14W400.copyWith(
                                      color: c.greyDark,
                                    ),
                                  ),
                                ),
                              )
                            : ListView(
                                padding: context
                                    .padSym(h: 20)
                                    .copyWith(bottom: context.h(32)),
                                children: [
                                  ProfileDetailHeader(
                                    displayName: model.fullName,
                                    locationLabel: model.location,
                                    bio: model.bio,
                                    avatarUrl: model.avatarUrl,
                                    showTrophyBadge: true,
                                    nameStyle: t.style(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: c.onSurface,
                                      height: 1.2,
                                    ),
                                    bioStyle: t.text14W400.copyWith(
                                      color: c.greyDark,
                                      height: 1.45,
                                    ),
                                    locationStyle: t.text14W500.copyWith(
                                      color: c.greylight,
                                      height: 1.3,
                                    ),
                                  ),
                                  SizedBox(height: context.h(22)),
                                  ProfileDetailStatsRow(
                                    followersCount: model.followersCount,
                                    followingCount: model.followingCount,
                                    ratingValue: model.ratingValue,
                                    matchesPlayedValue:
                                        model.matchesPlayedValue,
                                    onFollowersTap: () =>
                                        model.openFollowers(context),
                                    onFollowingTap: () =>
                                        model.openFollowing(context),
                                  ),
                                  SizedBox(height: context.h(16)),
                                  NormalText(
                                    titleText: AppText.mySports,
                                    titleStyle: t.text16Bold.copyWith(
                                      color: c.greyDark,
                                    ),
                                  ),
                                  ...model.publicSportsForDisplay.map(
                                    (s) => ProfilePrivateSportRow(
                                      sportName: s.name,
                                      skillLabel: s.skill,
                                    ),
                                  ),
                                  if (model.hasReviews) ...[
                                    SizedBox(height: context.h(8)),
                                    NormalText(
                                      titleText: AppText.reviews,
                                      titleStyle: t.text16Bold.copyWith(
                                        color: c.greyDark,
                                      ),
                                    ),
                                    ...model.parsedReviews.map(
                                      (review) => Padding(
                                        padding: EdgeInsets.only(
                                          bottom: context.h(10),
                                        ),
                                        child: ProfileDetailReviewCard(
                                          reviewAuthor:
                                              review['author'] ?? '—',
                                          reviewDate: review['date'] ?? '',
                                          reviewBody: review['body'] ??
                                              AppText
                                                  .profilePlaceholderReview,
                                          reviewInitial:
                                              review['initial'] ?? '?',
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PrivateProfileShimmer extends StatelessWidget {
  const _PrivateProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: context.padSym(h: 20).copyWith(bottom: context.h(32)),
      children: [
        const Center(
          child: ShimmerBox(width: 96, height: 96, shape: BoxShape.circle),
        ),
        SizedBox(height: context.h(14)),
        const Center(child: ShimmerBox(width: 170, height: 18)),
        SizedBox(height: context.h(10)),
        const Center(child: ShimmerBox(width: 140, height: 12)),
        SizedBox(height: context.h(20)),
        Row(
          children: const [
            Expanded(child: ShimmerBox(height: 84)),
            SizedBox(width: 10),
            Expanded(child: ShimmerBox(height: 84)),
            SizedBox(width: 10),
            Expanded(child: ShimmerBox(height: 84)),
            SizedBox(width: 10),
            Expanded(child: ShimmerBox(height: 84)),
          ],
        ),
        SizedBox(height: context.h(18)),
        const ShimmerBox(width: 90, height: 16),
        SizedBox(height: context.h(12)),
        const ShimmerBox(height: 52),
        SizedBox(height: context.h(10)),
        const ShimmerBox(height: 52),
      ],
    );
  }
}
