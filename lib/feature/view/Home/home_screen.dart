import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Home/viewModel/home_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/detail_match_card.dart';
import 'package:sport_finding/feature/widget/card_icon_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
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
        builder: (context, model, child) => ListView(
          padding: context.padSym(h: 20),
          children: [
            AppBarWidget(
              leading: NormalText(
                titleText: AppText.sportFinding,
                titleFontSize: 18,
              ),
              onTapLast: () {},
            ),
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
                    titleText: AppText.heyGoodEvening,
                    subText: 'Shehzad Khan',
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(24)),
            SearchBarWidget(isShow: false),
            SizedBox(height: context.h(16)),
            Row(
              children: [
                Expanded(
                  child: CardWidget(
                    padding: context.padSym(h: 26, v: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CardIconWidget(imageAsset: AppAssets.addIcon),
                        SizedBox(height: context.h(8)),
                        NormalText(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          titleText: AppText.createMatch,
                          titleColor: AppColors.blackcolor,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: CardWidget(
                    padding: context.padSym(h: 26, v: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CardIconWidget(imageAsset: AppAssets.matchesIcon),
                        SizedBox(height: context.h(8)),
                        NormalText(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          titleText: AppText.findMatch,
                          titleColor: AppColors.blackcolor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: context.h(16)),
            SectionHeaderWidget(
              title: AppText.allUpcomingMatches,
              actionText: AppText.viewMatch,
              icon: AppAssets.nextIcon,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RoutesName.AllUpComingMatchesScreen,
                );
              },
            ),
            SizedBox(height: context.h(8)),
            SizedBox(
              height: context.h(180),
              child: ListView.separated(
                scrollDirection: Axis.horizontal, // ✅ horizontal scroll
                itemCount: model.descoverMatchData.length, // 4 items
                padding: context.padSym(h: 0),
                itemBuilder: (context, index) {
                  final match = model.descoverMatchData[index];

                  return SizedBox(
                    width: context.w(300),
                    child: DetailsMatchesCard(
                      cardOnTap: () {
                        print("Clicked Match ID: ${match.id}");
                      },
                      hostName: match.title,
                      matchName: match.sportType,
                      loc: match.location,
                      time: match.dateTime,
                      takenPlayer: match.participantsJoined,
                      totalPlayer: match.participantsTotal,
                      matchOnTap: () {},
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    SizedBox(width: context.w(12)),
              ),
            ),
            SectionHeaderWidget(title: AppText.popularSports),
            SizedBox(height: context.h(8)),

            SizedBox(
              height: context.h(120),
              width: double.infinity,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: model.sports.length,

                padding: context.padSym(h: 0),
                itemBuilder: (context, index) {
                  final sport = model.sports[index];

                  return CardWidget(
                    padding: context.padSym(h: 32, v: 18),
                    child: Column(
                      children: [
                        CardIconWidget(imageAsset: sport.imagePath),
                        NormalText(
                          titleText: sport.title,
                          titleStyle: context.appText.text16W500,
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(width: context.w(12));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
