import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/profile_detail_widgets.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/profile_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/custom_seeting_card.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/shimmer_loading.dart';
import 'package:sport_finding/feature/webwidget/web_dashboard_widgets.dart';

class WebProfileContent extends StatelessWidget {
  const WebProfileContent({
    super.key,
    required this.model,
    required this.notificationsEnabled,
    required this.isUpdatingPreference,
    required this.safeAvatarUrl,
    required this.onFollowersTap,
    required this.onFollowingTap,
    required this.onSwitchChanged,
    required this.onTapSetting,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    this.primaryActionLabel = AppText.message,
  });

  final ProfileScreenViewModel model;
  final bool notificationsEnabled;
  final bool isUpdatingPreference;
  final String? safeAvatarUrl;
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;
  final ValueChanged<bool> onSwitchChanged;
  final void Function(int index) onTapSetting;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;
  final String primaryActionLabel;

  @override
  Widget build(BuildContext context) {
    return MainFrame(
      showDecorationLayer: false,
      child: ListView(
        padding: context.padSym(h: 20, v: 20),
        children: [
          const WebDashboardTitle(
            title: 'Profile',
            subtitle: 'Start messaging now',
          ),
          SizedBox(height: context.h(16)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: context.w(260),
                child: WebDashboardPanel(
                  child: model.isLoading
                      ? const _WebProfileCardShimmer()
                      : Column(
                          children: [
                            AppAvatar(
                              size: context.w(128),
                              imageUrl: safeAvatarUrl,
                              fallbackText: model.fullName,
                              backgroundColor: context.appColors.white,
                              iconColor: context.appColors.primary,
                            ),
                            SizedBox(height: context.h(24)),
                            NormalText(
                              titleText: model.fullName.isNotEmpty
                                  ? model.fullName
                                  : 'Player',
                              titleAlign: TextAlign.center,
                              titleStyle: context.appText.text28W700.copyWith(
                                color: context.appColors.greyDark,
                              ),
                            ),

                            SizedBox(height: context.h(4)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: context.appColors.greyDark,
                                ),
                                SizedBox(width: context.w(6)),
                                Flexible(
                                  child: Text(
                                    model.location.isNotEmpty
                                        ? model.location
                                        : AppText.profilePlaceholderLocation,
                                    textAlign: TextAlign.center,
                                    style: context.appText.text14W400.copyWith(
                                      color: context.appColors.greyDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.h(24)),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    padding: context.padAll(6),
                                    text: primaryActionLabel,
                                    onTap: onPrimaryAction,
                                    color: context.appColors.primary,
                                    titleStyle: context.appText.text14W500
                                        .copyWith(
                                          color: context.appColors.onPrimary,
                                        ),
                                  ),
                                ),
                                SizedBox(width: context.w(10)),
                                InkWell(
                                  onTap: onSecondaryAction,
                                  borderRadius: BorderRadius.circular(
                                    context.radius(12),
                                  ),
                                  child: Container(
                                    padding: context.padAll(16),
                                    decoration: BoxDecoration(
                                      color: context.appColors.blue10,
                                      borderRadius: BorderRadius.circular(
                                        context.radius(12),
                                      ),
                                      border: Border.all(
                                        color: AppColors.whitecolor,
                                      ),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        AppAssets.follow,
                                        color: context.appColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(width: context.w(20)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _StatCard(
                          value: '${model.followersCount}',
                          label: AppText.followers,
                          onTap: onFollowersTap,
                        ),
                        SizedBox(width: context.w(16)),
                        _StatCard(
                          value: '${model.followingCount}',
                          label: AppText.following,
                          onTap: onFollowingTap,
                        ),
                        SizedBox(width: context.w(16)),
                        _StatCard(
                          value: model.ratingValue,
                          label: AppText.rating,
                        ),
                        SizedBox(width: context.w(16)),
                        _StatCard(
                          value: model.matchesPlayedLabel,
                          label: 'Matches Played',
                        ),
                      ],
                    ),
                    SizedBox(height: context.h(20)),
                    WebDashboardPanel(
                      padding: context.padAll(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'About',
                              style: context.appText.text18W400.copyWith(
                                color: context.appColors.onSurface,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              model.bio.isNotEmpty
                                  ? model.bio
                                  : 'Passionate athlete who loves team sports and meeting new players. Always up for a match!',
                              textAlign: TextAlign.start,
                              style: context.appText.text16W400.copyWith(
                                color: context.appColors.greylight,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(20)),
          WebDashboardPanel(
            child: Column(
              children: model.profileData.map((item) {
                final index = model.profileData.indexOf(item);
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == model.profileData.length - 1
                        ? 0
                        : context.h(8),
                  ),
                  child: CustomSettingCard(
                    icon: item['leading'],
                    title: item['title'],
                    subtitle: item['subtitle'],
                    trailingType: item['trailingType'],
                    switchValue: index == 2
                        ? notificationsEnabled
                        : item['switchValue'],
                    onSwitchChanged: index == 2
                        ? onSwitchChanged
                        : (val) {
                            model.toggleSwitch(index, val);
                          },
                    switchEnabled: index == 2 ? !isUpdatingPreference : true,
                    switchLoading: index == 2 ? isUpdatingPreference : false,
                    onTap: () => onTapSetting(index),
                  ),
                );
              }).toList(),
            ),
          ),
          if (model.hasReviews) ...[
            WebDashboardPanel(
              padding: context.padAll(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppText.reviews,
                    style: context.appText.text18W400.copyWith(
                      color: context.appColors.onSurface,
                    ),
                  ),
                  SizedBox(height: context.h(16)),
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
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, this.onTap});

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.radius(12)),
        child: WebDashboardPanel(
          backgroundColor: context.appColors.blue10,
          padding: context.padAll(24),
          child: Column(
            children: [
              Text(
                value,
                style: context.appText.text56W400.copyWith(
                  color: context.appColors.onSurface,
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: context.appText.text12W400.copyWith(
                  color: context.appColors.greyDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebProfileCardShimmer extends StatelessWidget {
  const _WebProfileCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ShimmerBox(width: 104, height: 104, shape: BoxShape.circle),
        SizedBox(height: 16),
        ShimmerBox(width: 140, height: 18),
        SizedBox(height: 10),
        ShimmerBox(width: 120, height: 12),
        SizedBox(height: 18),
        ShimmerBox(height: 42),
      ],
    );
  }
}
