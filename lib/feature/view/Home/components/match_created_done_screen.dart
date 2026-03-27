import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view/Home/viewModel/match_created_done_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/social_button_widget.dart';

class MatchCreatedDoneScreen extends StatefulWidget {
  const MatchCreatedDoneScreen({super.key});

  @override
  State<MatchCreatedDoneScreen> createState() => _MatchCreatedDoneScreenState();
}

class _MatchCreatedDoneScreenState extends State<MatchCreatedDoneScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MatchCreatedDoneScreenViewModel>(
      builder: (context, model, child) => Scaffold(
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: context.h(5),
              bottom: context.h(20),
              right: context.w(20),
              left: context.w(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // IMPORTANT 🔥
              children: [
                SocialButtonWidget(
                  imagePath: AppAssets.invitedPeopleIcon,
                  text: AppText.invitedPlayers,
                  backgroundColor: context.appColors.primary,
                  // borderColor: Colors.grey.shade300,
                  textColor: context.appColors.onPrimary,
                ),

                SizedBox(height: context.h(12)),
                SocialButtonWidget(
                  imagePath: AppAssets.shareIcon,
                  text: AppText.shareMatch,
                  onTap: () {
                    print("Google Login");
                  },
                ),
                SizedBox(height: context.h(12)),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppAssets.viewMatchIcon),
                      SizedBox(width: context.w(8)),
                      NormalText(
                        subText: AppText.viewMatch,
                        subColor: context.appColors.greylight,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: MainFrame(
          child: ListView(
            padding: context.padSym(h: 20),
            children: [
              AppBarWidget(
                onTapFirst: () => Navigator.pop(context),
                title: AppText.sportFinding,
              ),
              SizedBox(height: context.h(236)),
              SvgPicture.asset(
                AppAssets.matchCreatedDoneIcon,
                fit: BoxFit.scaleDown,
              ),
              NormalText(
                crossAxisAlignment: CrossAxisAlignment.center,
                titleText: AppText.matchCreated,
                subAlign: TextAlign.center,
                subText: AppText.yourMatchIsLiveShareItWithFriends,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
