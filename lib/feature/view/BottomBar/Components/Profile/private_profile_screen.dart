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

class PrivateProfileScreen extends StatelessWidget {
  const PrivateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PublicProfileViewModel(
        args: PublicProfileArgs.privateProfilePreview(),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: MainFrame(
          child: Consumer<PublicProfileViewModel>(
            builder: (context, model, _) {
              final c = context.appColors;
              final t = context.appText;
              return Column(
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
                        ? Center(
                            child: CircularProgressIndicator(color: c.primary),
                          )
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
                              SizedBox(height: context.h(8)),
                              NormalText(
                                titleText: AppText.reviews,
                                titleStyle: t.text16Bold.copyWith(
                                  color: c.greyDark,
                                ),
                              ),
                              ProfileDetailReviewCard(
                                reviewAuthor: model.reviewAuthorForDisplay,
                                reviewDate: model.reviewDateForDisplay,
                                reviewBody: model.reviewBodyForDisplay,
                                reviewInitial: model.reviewInitial,
                              ),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
