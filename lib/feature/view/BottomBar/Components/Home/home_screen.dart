import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Home/viewModel/home_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/global_match_card.dart';
import 'package:sport_finding/feature/widget/card_icon_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';
import 'package:sport_finding/feature/widget/section_header_widget.dart';
import 'package:sport_finding/feature/widget/user_greeting_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeScreenViewModel>(
      builder: (context, model, child) {
        return ListView(
          padding: context.padSym(h: 20),
          children: [
            if (widget.showAppBar) ...[
              AppBarWidget(
                leading: NormalText(
                  titleText: AppText.sportFinding,
                  titleFontSize: 18,
                ),
                onTapLast: () {},
              ),
            ],
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
                title: model.timeGreeting,
                locName: model.fullName.isNotEmpty ? model.fullName : "Friend",
                imageUrl: model.avatarUrl,
                isShow: false,
              ),

            SizedBox(height: context.h(24)),
            SearchBarWidget(isShow: false),
            SizedBox(height: context.h(16)),
            Row(
              children: [
                Expanded(
                  child: CardWidget(
                    borderColor: isSelected
                        ? context.appColors.primary
                        : context.appColors.blue10,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RoutesName.createMatchScreen,
                      );
                    },
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
                    onTap: () {
                      context.read<BottomBarScreenViewModel>().setSelectedIndex(
                        1,
                      );
                    },
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
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RoutesName.allUpComingMatchesScreen,
                );
              },
            ),
            SizedBox(height: context.h(8)),
            // Shared match row: GlobalMatchCard (same as Discover / All Upcoming).
            SizedBox(
              height: GlobalMatchCard.listSlotHeight(context),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: model.matches.length,
                padding: context.padSym(h: 0),
                itemBuilder: (context, index) {
                  final match = model.matches[index];

                  return SizedBox(
                    width: context.w(300),
                    child: GlobalMatchCard.fromDiscovery(match),
                  );
                },
                separatorBuilder: (context, index) =>
                    SizedBox(width: context.w(12)),
              ),
            ),
            SectionHeaderWidget(title: AppText.popularSports),
            SizedBox(height: context.h(8)),

            SizedBox(
              height: context.h(140),
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
        );
      },
    );
  }
}
