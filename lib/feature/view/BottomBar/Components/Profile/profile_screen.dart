import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/core.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/edit_profile_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/profile_detail_widgets.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/profile_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/custom_seeting_card.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/user_greeting_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.embedInBottomBar = false});

  final bool embedInBottomBar;

  /// Returns a valid http URL or null — prevents passing placeholder
  /// strings like "default avatar url" to Image.network.
  static String? _safeAvatarUrl(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    return trimmed.startsWith('http') ? trimmed : null;
  }

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
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: SvgPicture.asset(AppAssets.notificationIcon),
                    ),
                  ),
                NormalText(titleText: AppText.profile),
                SizedBox(height: context.h(16)),
                if (model.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 16),
                        Text("Loading profile..."),
                      ],
                    ),
                  )
                else
                  UserGreetingWidget(
                    imageUrl: _safeAvatarUrl(model.avatarUrl),
                    title: model.fullName,
                    locName: model.location,
                    subTitle: model.bio,
                    isShow: model.bio.isNotEmpty,
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(
                              initialName: model.fullName,
                              initialBio: model.bio.isNotEmpty
                                  ? model.bio
                                  : null,
                              initialAvatarUrl: _safeAvatarUrl(model.avatarUrl),
                            ),
                          ),
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
