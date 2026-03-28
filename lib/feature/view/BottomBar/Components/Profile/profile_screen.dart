import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/profile_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/custom_seeting_card.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/user_greeting_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileScreenViewModel(),
      child: Consumer<ProfileScreenViewModel>(
        builder: (context, model, _) {
          return MainFrame(
            child: ListView(
              padding: context.padSym(h: 20),
              children: [
                AppBarWidget(
                  onTapFirst: () => Navigator.pop(context),

                  leading: NormalText(titleText: AppText.sportFinding),
                  trailing: SvgPicture.asset(AppAssets.notificationIcon),
                ),

                NormalText(titleText: AppText.profile),
                UserGreetingWidget(
                  title: "Shehzad (Host)",
                  name: AppText.newYorkUsa,
                  title2: AppText.passionateAboutSportsAndFitness,
                  isShow: true,
                ),
                SizedBox(height: context.h(16)),
                Row(
                  children: [
                    Expanded(
                      child: CardWidget(
                        padding: context.padSym(h: 22, v: 18),
                        child: NormalText(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          titleText: '45',
                          subText: AppText.followers,
                          subColor: context.appColors.greylight,
                        ),
                      ),
                    ),
                    SizedBox(width: context.w(12)),
                    Expanded(
                      child: CardWidget(
                        padding: context.padSym(h: 22, v: 18),
                        child: NormalText(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          titleText: '45',
                          subText: AppText.following,
                          subColor: context.appColors.greylight,
                        ),
                      ),
                    ),
                    SizedBox(width: context.w(12)),

                    Expanded(
                      child: CardWidget(
                        padding: context.padSym(h: 22, v: 18),
                        child: NormalText(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          titleText: '45',
                          subText: AppText.matching,
                          subColor: context.appColors.greylight,
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

                      /// 🔥 SWITCH HANDLER
                      onSwitchChanged: (val) {
                        model.toggleSwitch(index, val);
                      },

                      /// 🔥 TAP HANDLER
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
                    return ProfileMySportCardWidget(
                      sportName: sport.name,
                      buttonName: sport.skill,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileMySportCardWidget extends StatelessWidget {
  final String sportName;
  final String buttonName;
  const ProfileMySportCardWidget({
    super.key,
    required this.sportName,
    required this.buttonName,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      padding: context.padSym(h: 16, v: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NormalText(subText: sportName),
          CardWidget(
            padding: context.padSym(h: 24, v: 8),

            child: NormalText(
              titleText: buttonName,

              titleColor: context.appColors.greyDark,
              titleFontSize: context.text(13),
              titleFontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
