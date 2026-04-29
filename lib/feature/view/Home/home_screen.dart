import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/DeleteMAtch/delete_match_Model.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/Data/model/all_matches_model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/home_screen_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/upcoming_matches_scope.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/global_match_card.dart';
import 'package:sport_finding/feature/widget/card_icon_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';
import 'package:sport_finding/feature/widget/section_header_widget.dart';
import 'package:sport_finding/feature/widget/shimmer_loading.dart';
import 'package:sport_finding/feature/widget/user_greeting_widget.dart';
import 'package:sport_finding/feature/widget/web_dashboard_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSelected = false;

  Future<void> _openMatchDetails(
    BuildContext context,
    HomeScreenViewModel model,
    DiscoveryMatch match,
  ) async {
    final result = await Navigator.pushNamed(
      context,
      match.isHostedByCurrentUser
          ? RoutesName.hostDetailsScreen
          : RoutesName.userMatchDetailsScreen,
      arguments: match,
    );

    if (!context.mounted) return;
    if (result is DeleteMatchModel) {
      model.removeMatchById(result.matchId);
      AppSnackBar.show(
        AppText.matchDeletedSuccessfully,
        backgroundColor: context.appColors.primary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeScreenViewModel>(
      builder: (context, model, child) {
        if (kIsWeb) {
          return _WebHomeContent(model: model);
        }
        return ListView(
          padding: context.padSym(h: 20),
          children: [
            if (widget.showAppBar) ...[
              AppBarWidget(
                leading: NormalText(
                  titleText: AppText.sportFinding,
                  titleFontSize: 18,
                ),
              ),
            ],
            if (model.isLoading)
              const _HomeGreetingShimmer()
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
                    // padding: context.padSym(h: 26, v: 18),
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
                    // padding: context.padSym(h: 26, v: 18),
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
              actionText: AppText.seeAll,
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
            ),
            SizedBox(height: context.h(8)),
            SizedBox(
              height: GlobalMatchCard.listSlotHeight(context),
              child: model.matchesLoading
                  ? const _HomeMatchesShimmer()
                  : model.matches.isEmpty
                  ? Center(
                      child: NormalText(
                        titleText: AppText.noMatchesFound,
                        titleStyle: context.appText.text14W500,
                      ),
                    )
                  : ListenableBuilder(
                      listenable: ProfileService(),
                      builder: (context, _) {
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: model.matches.length > 4
                              ? 4
                              : model.matches.length,
                          padding: context.padSym(h: 0),
                          itemBuilder: (context, index) {
                            final match = model.matches[index];

                            return SizedBox(
                              width: context.w(300),
                              child: GlobalMatchCard.fromAllMatches(
                                key: ValueKey<String>('match-${match.id}'),
                                match,

                                onCardTap: () => _openMatchDetails(
                                  context,
                                  model,
                                  DiscoveryMatch.fromAllMatches(match),
                                ),
                                onSeeAllTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    RoutesName.seeAllInvatedPlayerScreen,
                                    arguments: match,
                                  );
                                },
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(width: context.w(12)),
                        );
                      },
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

class _WebHomeContent extends StatelessWidget {
  const _WebHomeContent({required this.model});

  final HomeScreenViewModel model;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: context.padSym(h: 20, v: 8),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: context.radiusR(20),
              backgroundImage:
                  model.avatarUrl.trim().isNotEmpty ? NetworkImage(model.avatarUrl) : null,
              child: model.avatarUrl.trim().isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            SizedBox(width: context.w(12)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.timeGreeting,
                  style: context.appText.text14W500.copyWith(
                    color: context.appColors.onSurface,
                  ),
                ),
                Text(
                  model.fullName.isNotEmpty ? model.fullName : 'Player',
                  style: context.appText.text12W400.copyWith(
                    color: context.appColors.greylight,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: context.h(18)),
        SearchBarWidget(isShow: false),
        SizedBox(height: context.h(16)),
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
                  context.read<BottomBarScreenViewModel>().setSelectedIndex(1);
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
              ? const _HomeMatchesShimmer()
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: model.matches.length > 4 ? 4 : model.matches.length,
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
    );
  }
}

class _HomeGreetingShimmer extends StatelessWidget {
  const _HomeGreetingShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: const [
          ShimmerBox(width: 44, height: 44, shape: BoxShape.circle),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShimmerBox(width: 140, height: 14, radius: 8),
                SizedBox(height: 10),
                ShimmerBox(width: 110, height: 12, radius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeMatchesShimmer extends StatelessWidget {
  const _HomeMatchesShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 2,
      padding: EdgeInsets.zero,
      separatorBuilder: (_, _) => SizedBox(width: context.w(12)),
      itemBuilder: (context, _) {
        return SizedBox(
          width: context.w(300),
          child: CardWidget(
            child: Padding(
              padding: context.padSym(h: 16, v: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  ShimmerBox(width: 140, height: 16),
                  SizedBox(height: 12),
                  ShimmerBox(width: 100, height: 12),
                  SizedBox(height: 18),
                  ShimmerBox(height: 12),
                  SizedBox(height: 10),
                  ShimmerBox(width: 180, height: 12),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(width: 70, height: 12),
                      ShimmerBox(width: 44, height: 44, shape: BoxShape.circle),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
