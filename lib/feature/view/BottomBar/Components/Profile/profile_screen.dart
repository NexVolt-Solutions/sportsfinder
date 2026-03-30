import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/core.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/profile_detail_widgets.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/profile_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/custom_seeting_card.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/user_greeting_widget.dart';

/// Light outline for profile secondary actions. [AppColors.greylight] is a translucent *dark* grey, so it disappears on [AppColors.blue10].
const Color _kProfileActionOutline = Color(0xFFCCCCCC);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.embedInBottomBar = false});

  /// When true, [BottomBarScreen] supplies the shared [AppBarWidget].
  final bool embedInBottomBar;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileScreenViewModel(),
      child: Consumer<ProfileScreenViewModel>(
        builder: (context, model, _) {
          return MainFrame(
            showDecorationLayer: !embedInBottomBar,
            child: ListView(
              padding: context
                  .padSym(h: 20)
                  .copyWith(
                    bottom: embedInBottomBar ? context.h(100) : context.h(24),
                  ),
              children: [
                if (!embedInBottomBar)
                  AppBarWidget(
                    onTapFirst: () => Navigator.pop(context),
                    leading: NormalText(titleText: AppText.sportFinding),
                    trailing: GestureDetector(
                      onTap: () => model.openNotifications(context),
                      behavior: HitTestBehavior.opaque,
                      child: SvgPicture.asset(AppAssets.notificationIcon),
                    ),
                  ),
                NormalText(titleText: AppText.profile),
                SizedBox(height: context.h(16)),
                UserGreetingWidget(
                  title: model.profileDisplayName,
                  name: model.profileLocation,
                  title2: model.profileBio,
                  isShow: model.showBioOnProfile,
                ),
                SizedBox(height: context.h(16)),
                Row(
                  children: [
                    Expanded(
                      child: CardWidget(
                        onTap: () => model.openFollowers(context),
                        padding: context.padSym(h: 22, v: 18),
                        child: NormalText(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          titleText: model.followersCountLabel,
                          subText: AppText.followers,
                          subStyle: context.appText.text12W400.copyWith(
                            color: context.appColors.greyDark,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.w(12)),
                    Expanded(
                      child: CardWidget(
                        onTap: () => model.openFollowing(context),
                        padding: context.padSym(h: 22, v: 18),
                        child: NormalText(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          titleText: model.followingCountLabel,
                          subText: AppText.following,
                          subStyle: context.appText.text12W400.copyWith(
                            color: context.appColors.greyDark,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.w(12)),
                    Expanded(
                      child: CardWidget(
                        padding: context.padSym(h: 22, v: 18),
                        child: NormalText(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          titleText: model.matchesPlayedLabel,
                          subText: AppText.matches,
                          subStyle: context.appText.text12W400.copyWith(
                            color: context.appColors.greyDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                  itemCount: model.profileData.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = model.profileData[index];

                    return CustomSettingCard(
                      icon: item['leading'],
                      title: item['title'],
                      subtitle: item['subtitle'],
                      trailingType: item['trailingType'],
                      switchValue: item['switchValue'],
                      onSwitchChanged: (val) {
                        model.toggleSwitch(index, val);
                      },
                      onTap: () => model.onTapFun(context, index),
                    );
                  },
                ),
                NormalText(titleText: AppText.mySports),
                ListView.builder(
                  itemCount: model.sportsList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final sport = model.sportsList[index];
                    return ProfilePrivateSportRow(
                      sportName: sport.name,
                      skillLabel: sport.skill,
                    );
                  },
                ),
                SizedBox(height: context.h(16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomButton(
                        color: context.appColors.transparent,

                        outlined: true,
                        titleStyle: context.appText.text16Bold.copyWith(
                          color: AppColors.bluecolor,
                        ),
                        leading: SvgPicture.asset(AppAssets.edit),
                        borderColor: AppColors.bluecolor,
                        radius: BorderRadius.circular(context.radiusR(12)),
                        onTap: () => Navigator.pushNamed(
                          context,
                          RoutesName.editProfileRoute,
                        ),
                        text: AppText.editProfile,
                      ),
                    ),
                    SizedBox(width: context.w(12)),
                    Expanded(
                      child: CustomButton(
                        color: context.appColors.transparent,
                        outlined: true,
                        titleStyle: context.appText.text16Bold.copyWith(
                          color: AppColors.bluecolor,
                        ),
                        leading: SvgPicture.asset(AppAssets.share),
                        borderColor: AppColors.bluecolor,
                        radius: BorderRadius.circular(context.radiusR(12)),
                        onTap: () {},

                        text: AppText.share,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
