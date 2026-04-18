import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/discovery_match_navigation.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Home/viewModel/all_upcomming_matches_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/upcoming_matches_scope.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/filter_bottom_sheet_widget_v2.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/global_match_card.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';

class AllUpcomingMatches extends StatefulWidget {
  const AllUpcomingMatches({
    super.key,
    this.embedAsBottomTab = false,
    this.listTitle,
  });

  final bool embedAsBottomTab;

  final String? listTitle;

  @override
  State<AllUpcomingMatches> createState() => _AllUpcomingMatchesState();
}

class _AllUpcomingMatchesState extends State<AllUpcomingMatches> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AllUpcommingMatchesViewModel>(
      builder: (context, model, _) {
        final content = Padding(
          padding: context.padSym(h: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.embedAsBottomTab)
                AppBarWidget(
                  title: AppText.upcomingMatches,
                  showBackButton: true,
                ),
              NormalText(
                crossAxisAlignment: CrossAxisAlignment.start,
                titleText: widget.listTitle ?? AppText.sportFinding,
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
                          model.applyFilters(filterData);
                        },
                      );
                    },
                  );
                },
              ),
              SizedBox(height: context.h(16)),
              // Categories tabs removed (All / Football / Basketball / etc.).
              SizedBox.shrink(),
              Expanded(
                child: model.matches.isEmpty
                    ? Center(
                        child: Padding(
                          padding: context.padSym(h: 16),
                          child: Text(
                            model.listScope == UpcomingMatchesScope.myMatches
                                ? AppText.noHostedMatchesYet
                                : AppText.noMatchesFound,
                            textAlign: TextAlign.center,
                            style: context.appText.text14W400.copyWith(
                              color: context.appColors.greyDark,
                            ),
                          ),
                        ),
                      )
                    : ListenableBuilder(
                        listenable: ProfileService(),
                        builder: (context, _) {
                          return ListView.separated(
                            itemCount: model.matches.length,
                            padding: context.padSym(h: 0),
                            itemBuilder: (context, index) {
                              final match = model.matches[index];

                              return GlobalMatchCard.fromAllMatches(
                                match,
                                onCardTap: () {
                                  DiscoveryMatch.fromAllMatches(
                                    match,
                                  ).pushMatchOrHostScreen(context);
                                },
                                onSeeAllTap: () {
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
                          );
                        },
                      ),
              ),
            ],
          ),
        );

        if (widget.embedAsBottomTab) {
          return SizedBox.expand(child: content);
        }
        return Scaffold(body: MainFrame(child: content));
      },
    );
  }
}
