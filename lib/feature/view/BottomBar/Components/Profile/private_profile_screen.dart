import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/edit_profile_route_args.dart';
import 'package:sport_finding/Data/model/public_profile_args.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/edit_profile_sports_mapping.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/profile_detail_widgets.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/public_profile_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/shimmer_loading.dart';
import 'package:sport_finding/feature/webwidget/web_dashboard_widgets.dart';
import 'package:sport_finding/feature/webwidget/web_profile_content.dart';

class PrivateProfileScreen extends StatelessWidget {
  const PrivateProfileScreen({super.key});

  void _openEditProfile(BuildContext context) {
    final ps = ProfileService().profile;
    String? sportUi;
    String? skillUi;
    if (ps != null && ps.sports.isNotEmpty) {
      final raw = ps.sports.first;
      if (raw is Map) {
        final m = Map<String, dynamic>.from(raw);
        sportUi = apiSportToUiDropdown(m['sport']?.toString());
        skillUi = apiSkillToUiDropdown(
          (m['skill_level'] ?? m['skill'])?.toString(),
        );
      }
    }
    Navigator.pushNamed(
      context,
      RoutesName.editProfileRoute,
      arguments: EditProfileRouteArgs(
        initialName: ProfileService().fullName,
        initialBio: ProfileService().bio.isNotEmpty ? ProfileService().bio : null,
        initialAvatarUrl: ProfileService().avatarUrl,
        initialSport: sportUi,
        initialSkill: skillUi,
      ),
    );
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

            if (kIsWeb) {
              if (model.showSpinner) {
                return const _PrivateProfileShimmer();
              }
              if (model.showError) {
                return Center(
                  child: Text(
                    model.displayError,
                    textAlign: TextAlign.center,
                    style: t.text14W400.copyWith(color: c.greyDark),
                  ),
                );
              }
              return WebProfileContent(
                title: AppText.privateProfile,
                subtitle: 'Start messaging now',
                displayName: model.fullName,
                location: model.location,
                bio: model.bio,
                safeAvatarUrl: model.avatarUrl,
                isLoading: false,
                followersValue: '${model.followersCount}',
                followingValue: '${model.followingCount}',
                ratingValue: model.ratingValue,
                matchesPlayedValue: model.matchesPlayedValue,
                onFollowersTap: () => model.openFollowers(context),
                onFollowingTap: () => model.openFollowing(context),
                onBackTap: () => Navigator.pop(context),
                headerActionText: AppText.editProfile,
                onHeaderActionTap: () => _openEditProfile(context),
                showHeaderText: false,
                footerSection: model.hasReviews
                    ? WebDashboardPanel(
                        padding: context.padAll(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppText.reviews,
                              style: t.text18W400.copyWith(
                                color: c.onSurface,
                              ),
                            ),
                            SizedBox(height: context.h(16)),
                            ...model.parsedReviews.map(
                              (review) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: context.h(10),
                                ),
                                child: ProfileDetailReviewCard(
                                  reviewAuthor: review['author'] ?? '—',
                                  reviewDate: review['date'] ?? '',
                                  reviewBody:
                                      review['body'] ??
                                      AppText.profilePlaceholderReview,
                                  reviewInitial: review['initial'] ?? '?',
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              );
            }

            return MainFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: context.padSym(h: 20),
                    child: AppBarWidget(
                      title: AppText.privateProfile,
                      onLeadingTap: () => Navigator.pop(context),
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
                                style: t.text14W400.copyWith(color: c.greyDark),
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
                                matchesPlayedValue: model.matchesPlayedValue,
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
                                      reviewAuthor: review['author'] ?? '—',
                                      reviewDate: review['date'] ?? '',
                                      reviewBody:
                                          review['body'] ??
                                          AppText.profilePlaceholderReview,
                                      reviewInitial: review['initial'] ?? '?',
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
