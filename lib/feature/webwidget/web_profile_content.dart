import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/profile_detail_widgets.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/profile_screen_view_model.dart';
import 'package:sport_finding/feature/widget/custom_seeting_card.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/shimmer_loading.dart';
import 'package:sport_finding/feature/widget/user_greeting_widget.dart';
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
  });

  final ProfileScreenViewModel model;
  final bool notificationsEnabled;
  final bool isUpdatingPreference;
  final String? safeAvatarUrl;
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;
  final ValueChanged<bool> onSwitchChanged;
  final void Function(int index) onTapSetting;

  @override
  Widget build(BuildContext context) {
    return MainFrame(
      showDecorationLayer: false,
      child: Padding(
        padding: context.padSym(h: 20, v: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WebDashboardTitle(
              title: 'Profile',
              subtitle: 'Manage your personal info and account settings.',
            ),
            SizedBox(height: context.h(16)),
            Expanded(
              child: WebDashboardPanel(
                child: ListView(
                  children: [
                    if (model.isLoading)
                      const _WebProfileGreetingShimmer()
                    else
                      UserGreetingWidget(
                        imageUrl: safeAvatarUrl,
                        title: model.fullName,
                        locName: model.location,
                        subTitle: model.bio,
                        isShow: model.bio.isNotEmpty,
                      ),
                    SizedBox(height: context.h(16)),
                    ProfileDetailStatsRow(
                      followersCount: model.followersCount,
                      followingCount: model.followingCount,
                      ratingValue: model.ratingValue,
                      matchesPlayedValue: model.matchesPlayedLabel,
                      onFollowersTap: onFollowersTap,
                      onFollowingTap: onFollowingTap,
                    ),
                    SizedBox(height: context.h(18)),
                    ...model.profileData.map((item) {
                      final index = model.profileData.indexOf(item);
                      return CustomSettingCard(
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
                        switchEnabled: index == 2
                            ? !isUpdatingPreference
                            : true,
                        switchLoading: index == 2
                            ? isUpdatingPreference
                            : false,
                        onTap: () => onTapSetting(index),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebProfileGreetingShimmer extends StatelessWidget {
  const _WebProfileGreetingShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: const [
          ShimmerBox(width: 44, height: 44, shape: BoxShape.circle),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShimmerBox(width: 130, height: 14),
                SizedBox(height: 10),
                ShimmerBox(width: 110, height: 12),
                SizedBox(height: 10),
                ShimmerBox(width: 180, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
