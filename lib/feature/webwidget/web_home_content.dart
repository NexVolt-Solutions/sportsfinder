import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/all_matches_model.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/home_screen_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/upcoming_matches_scope.dart';
import 'package:sport_finding/feature/widget/card_icon_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';
import 'package:sport_finding/feature/widget/shimmer_loading.dart';
import 'package:sport_finding/feature/webwidget/web_dashboard_widgets.dart';

class WebHomeContent extends StatelessWidget {
  const WebHomeContent({super.key, required this.model});

  final HomeScreenViewModel model;

  @override
  Widget build(BuildContext context) {
    return MainFrame(
      showDecorationLayer: true,
      child: ListView(
        padding: context.padSym(h: 48, v: 36),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: context.radiusR(24),
                backgroundImage: model.avatarUrl.trim().isNotEmpty
                    ? NetworkImage(model.avatarUrl)
                    : null,
                child: model.avatarUrl.trim().isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              SizedBox(width: context.w(12)),
              NormalText(
                titleText: model.timeGreeting,
                subText: model.fullName.isNotEmpty ? model.fullName : 'Player',
                subStyle: context.appText.text16W500.copyWith(
                  color: context.appColors.greylight,
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(48)),
          SearchBarWidget(isShow: false),
          SizedBox(height: context.h(48)),
          Row(
            children: [
              Expanded(
                child: WebQuickActionCard(
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: context.appColors.primary,
                  ),
                  title: 'Create Matches',
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.createMatchScreen);
                  },
                ),
              ),
              SizedBox(width: context.w(14)),
              Expanded(
                child: WebQuickActionCard(
                  icon: Icon(
                    Icons.search_rounded,
                    color: context.appColors.primary,
                  ),
                  title: 'Find Matches',
                  onTap: () {
                    context.read<BottomBarScreenViewModel>().setSelectedIndex(
                      1,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(22)),
          WebDashboardTitle(
            title: AppText.allUpcomingMatches,
            trailing: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RoutesName.allUpComingMatchesScreen,
                  arguments: AllUpcomingMatchesRouteArgs(
                    scope: UpcomingMatchesScope.allUpcoming,
                    prefetchedMatches: List<AllMatches>.from(model.matches),
                    hasNext: model.hasMoreUpcoming,
                  ),
                );
              },
              child: Text(
                'View All',
                style: context.appText.text12W500.copyWith(
                  color: context.appColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: context.h(12)),
          SizedBox(
            height: context.h(176),
            child: model.matchesLoading
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 2,
                    itemBuilder: (context, _) {
                      return SizedBox(
                        width: context.w(210),
                        child: const WebDashboardPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(width: 120, height: 16),
                              SizedBox(height: 10),
                              ShimmerBox(width: 80, height: 12),
                              SizedBox(height: 12),
                              ShimmerBox(height: 12),
                              Spacer(),
                              ShimmerBox(width: 90, height: 12),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, _) => SizedBox(width: context.w(12)),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: model.matches.length > 4
                        ? 4
                        : model.matches.length,
                    itemBuilder: (context, index) {
                      final match = model.matches[index];
                      return SizedBox(
                        width: context.w(210),
                        child: WebDashboardPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                match.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.appText.text14W600.copyWith(
                                  color: context.appColors.onSurface,
                                ),
                              ),
                              SizedBox(height: context.h(6)),
                              Text(
                                match.sport,
                                style: context.appText.text12W400.copyWith(
                                  color: context.appColors.greylight,
                                ),
                              ),
                              SizedBox(height: context.h(10)),
                              Text(
                                match.locationName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.appText.text12W400.copyWith(
                                  color: context.appColors.greylight,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${match.currentPlayers}/${match.maxPlayers} players',
                                style: context.appText.text12W500.copyWith(
                                  color: context.appColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, _) => SizedBox(width: context.w(12)),
                  ),
          ),
          SizedBox(height: context.h(24)),
          const WebDashboardTitle(title: 'Popular Sports'),
          SizedBox(height: context.h(12)),
          Wrap(
            spacing: context.w(14),
            runSpacing: context.h(14),
            children: model.sports.map((sport) {
              return SizedBox(
                width: context.w(122),
                child: WebDashboardPanel(
                  padding: context.padSym(h: 14, v: 18),
                  child: Column(
                    children: [
                      CardIconWidget(imageAsset: sport.imagePath),
                      SizedBox(height: context.h(10)),
                      Text(
                        sport.title,
                        textAlign: TextAlign.center,
                        style: context.appText.text14W500.copyWith(
                          color: context.appColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
