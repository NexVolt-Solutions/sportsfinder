import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_styles.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view_model/home_screen_view_model.dart';
import 'package:sport_finding/feature/view_model/match_detai_card.dart';
import 'package:sport_finding/feature/widget/card_icon_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';
import 'package:sport_finding/feature/widget/section_header_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeScreenViewModel(),
      child: Consumer<HomeScreenViewModel>(
        builder: (context, model, child) => Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: MainFrame(
              child: ListView(
                padding: context.padSym(h: 20),
                children: [
                  SizedBox(height: context.h(20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NormalText(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        titleText: AppText.appName,
                        titleStyle: context.appText.text18W600,
                        titleColor: context.appColors.onSurface,
                      ),
                      SvgPicture.asset(AppAssets.notificationIcon),
                    ],
                  ),
                  SizedBox(height: context.h(24)),
                  Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.appColors.greyDark,
                        ),
                      ),
                      SizedBox(width: context.w(16)),
                      Expanded(
                        child: NormalText(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          titleText: AppText.goodEvening,
                          titleStyle: context.appText.text18W600,
                          titleColor: context.appColors.onSurface,
                          subText: 'Shehzad Khan',
                          subStyle: context.appText.text16W400,
                          subColor: context.appColors.greylight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(20)),
                  SearchBarWidget(),
                  SizedBox(height: context.h(20)),
                  Row(
                    children: [
                      Expanded(
                        child: CardWidget(
                          padding: context.padSym(h: 26, v: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CardIconWidget(imageAsset: AppAssets.addIcon),
                              SizedBox(height: context.h(8)),
                              NormalText(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                titleText: "Create Matches",
                                titleColor: AppColors.blackcolor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: context.w(12)),
                      Expanded(
                        child: CardWidget(
                          padding: context.padSym(h: 26, v: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CardIconWidget(imageAsset: AppAssets.matchesIcon),
                              SizedBox(height: context.h(8)),
                              NormalText(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                titleText: "Find Matches",
                                titleColor: AppColors.blackcolor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(20)),
                  SectionHeaderWidget(
                    title: AppText.createMatchTitle,
                    actionText: AppText.viewAll,
                    icon: AppAssets.nextIcon,
                  ),
                  SizedBox(height: context.h(12)),
                  SizedBox(
                    height: context.h(200),
                    width: double
                        .infinity, // no need for context.w(double.infinity)
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4, // Show 4 cards
                      padding: context.padSym(h: 0), // Optional padding
                      itemBuilder: (context, index) {
                        return MatchDetilCard(
                          headingtitle: 'Khan Match',
                          headingSubtitle: AppText.basketball,
                          loc: AppText.locationLabel,
                          time: '16/03/2026, 7:00 PM',
                          palyerNo: '10/10',
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          width: context.w(12),
                        ); // Horizontal spacing between cards
                      },
                    ),
                  ),
                  SizedBox(height: context.h(20)),
                  SectionHeaderWidget(title: AppText.popularSports),
                  SizedBox(height: context.h(16)),
                  SizedBox(
                    height: context.h(130),
                    width: double
                        .infinity, // no need for context.w(double.infinity)
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4, // Show 4 cards
                      padding: context.padSym(h: 0), // Optional padding
                      itemBuilder: (context, index) {
                        return CardWidget(
                          padding: context.padSym(h: 34, v: 18),
                          child: Column(
                            children: [
                              CardIconWidget(
                                imageAsset: AppAssets.footBallIcon,
                              ),
                              NormalText(
                                titleText: AppText.football,
                                titleColor: context.appColors.greyDark,
                                titleStyle: context.appText.text14W600,
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          width: context.w(12),
                        ); // Horizontal spacing between cards
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
