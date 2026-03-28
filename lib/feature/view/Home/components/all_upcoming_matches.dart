import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Home/viewModel/all_upcomming_matches_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/filter_bottom_sheet_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/detail_match_card.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';

class AllUpcomingMatches extends StatefulWidget {
  const AllUpcomingMatches({super.key});

  @override
  State<AllUpcomingMatches> createState() => _AllUpcomingMatchesState();
}

class _AllUpcomingMatchesState extends State<AllUpcomingMatches> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AllUpcommingMatchesViewModel>(
      builder: (context, model, child) => Scaffold(
        body: MainFrame(
          child: Padding(
            padding: context.padSym(h: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBarWidget(
                  leading: NormalText(
                    titleText: AppText.sportFinding,
                    titleFontSize: 18,
                  ),
                  onTapLast: () {},
                ),

                NormalText(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  maxLines: 2,
                  titleText: AppText.allUpcomingMatches,
                  titleStyle: context.appText.text18W600,
                  titleColor: context.appColors.onSurface,
                ),
                SizedBox(height: context.h(16)),

                SearchBarWidget(
                  isShow: true,
                  onChanged: (text) {
                    model.searchMatches(text);
                  },
                  onFilterTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return FilterBottomSheet(
                          onApply: (filterData) {
                            // Handle filter application
                            print('Sport Index: ${filterData.sportIndex}');
                            print('Skill Level: ${filterData.skillLevel}');
                            print('Distance: ${filterData.distance} km');
                            print('Time: ${filterData.time?.format(context)}');
                            print('Date: ${filterData.date}');

                            // Apply filters to your ViewModel
                            model.applyFilters(filterData);
                          },
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: context.h(16)),

                SizedBox(
                  height: context.h(65),
                  width: context.w(double.infinity),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: model.upComingMatchesText.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final upComingMatches = model.upComingMatchesText[index];

                      return CardWidget(
                        padding: context.padSym(h: 22, v: 7),
                        isActive:
                            model.selectedIndex ==
                            index, // ✅ highlight selected
                        activeBorderColor:
                            context.appColors.primary, // optional custom color
                        onTap: () {
                          model.filterMatches(
                            index,
                          ); // filter matches & update selectedIndex
                        },
                        child: NormalText(
                          titleText: upComingMatches.text,
                          titleStyle: context.appText.text16W500,
                          titleColor: model.selectedIndex == index
                              ? context.appColors.primary
                              : context.appColors.greylight,
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        SizedBox(width: context.w(12)),
                  ),
                ),

                Expanded(
                  child: ListView.separated(
                    itemCount: model.matches.length,
                    padding: context.padSym(h: 0),
                    itemBuilder: (context, index) {
                      final match = model.matches[index];

                      return DetailsMatchesCard(
                        cardOnTap: () {
                          Navigator.pushNamed(
                            context,
                            RoutesName.userMatchDetailsScreen,
                            arguments: match,
                          );
                        },
                        hostName: match.title,
                        matchName: match.sportType,
                        loc: match.location,
                        time: match.date,
                        takenPlayer: match.participantsJoined,
                        totalPlayer: match.participantsTotal,
                        isActive: true,
                        distance: match.distanceKm,
                        matchOnTap: () {
                          Navigator.pushNamed(
                            context,
                            RoutesName.seeAllInvatedPlayerScreen,
                            arguments: match,
                          );
                        },
                      );
                    },
                    separatorBuilder: (context, index) =>
                        SizedBox(height: context.h(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
