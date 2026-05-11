import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/all_matches_model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/discovery_match_navigation.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/home_screen_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/upcoming_matches_scope.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';
import 'package:sport_finding/feature/widget/card_icon_widget.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';
import 'package:sport_finding/feature/widget/shimmer_loading.dart';
import 'package:sport_finding/feature/webwidget/web_dashboard_widgets.dart';

class WebHomeContent extends StatelessWidget {
  const WebHomeContent({super.key, required this.model});

  final HomeScreenViewModel model;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: context.padSym(h: 35, v: 24),
      children: [
        Row(
          children: [
            AppAvatar(
              size: context.h(48),
              imageUrl: model.avatarUrl,
              fallbackText: model.fullName,
            ),
            SizedBox(width: context.w(12)),
            NormalText(
              titleText: model.timeGreeting,
               subText: model.fullName.isNotEmpty ? model.fullName : 'Player',
              
            ),
          ],
        ),
        SizedBox(height: context.h(57)),
        SearchBarWidget(),
        SizedBox(height: context.h(36)),
        SizedBox(
          height: 106,
          child: Row(
            children: [
              Expanded(
                child: WebQuickActionCard(
                  icon: Icon(
                    Icons.add_rounded,
                    color: context.appColors.greyDark,
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
                    Icons.emoji_events_outlined,
                    color: context.appColors.greyDark,
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
        ),
        SizedBox(height: context.h(32)),
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
          height: 116,
          child: model.matchesLoading
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 2,
                  itemBuilder: (context, _) {
                    return SizedBox(
                      width: context.w(166),
                      child: const WebDashboardPanel(
                        padding: EdgeInsets.all(14),
                        backgroundColor: Color(0xFFEAF6FF),
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
                      width: context.w(166),
                      child: _WebHomeMatchCard(
                        match: match,
                        onTap: () {
                          DiscoveryMatch.fromAllMatches(
                            match,
                          ).pushMatchOrHostScreen(context);
                        },
                      ),
                    );
                  },
                  separatorBuilder: (_, _) => SizedBox(width: context.w(12)),
                ),
        ),
        SizedBox(height: context.h(64)),
        const WebDashboardTitle(title: 'Popular Sports'),
        SizedBox(height: context.h(12)),
        Wrap(
          spacing: context.w(14),
          runSpacing: context.h(14),
          children: model.sports.map((sport) {
            return SizedBox(
              width: context.w(108),
              height: 108,
              child: WebDashboardPanel(
                padding: context.padSym(h: 12, v: 12),
                backgroundColor: const Color(0xFFEAF6FF),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CardIconWidget(imageAsset: sport.imagePath),
                    SizedBox(height: context.h(8)),
                    Text(
                      sport.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class _WebHomeMatchCard extends StatelessWidget {
  const _WebHomeMatchCard({required this.match, required this.onTap});

  final AllMatches match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.radiusR(10)),
        child: WebDashboardPanel(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          backgroundColor: const Color(0xFFEAF6FF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      match.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appText.text14W600.copyWith(
                        color: c.onSurface,
                      ),
                    ),
                  ),
                  if (match.distanceKm != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${match.distanceKm!.toStringAsFixed(1)} km',
                        style: context.appText.text12W500.copyWith(
                          color: c.primary,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                match.sport,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appText.text12W400.copyWith(color: c.greyDark),
              ),
              const SizedBox(height: 8),
              _MatchMetaLine(
                icon: Icons.location_on_outlined,
                label: _matchLocation(match),
              ),
              const SizedBox(height: 5),
              _MatchMetaLine(
                icon: Icons.access_time_rounded,
                label: _matchSchedule(match),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.group_outlined, size: 13, color: c.greylight),
                  const SizedBox(width: 4),
                  Text(
                    '${match.currentPlayers}/${match.maxPlayers}',
                    style: context.appText.text12W600.copyWith(
                      color: c.onSurface,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchMetaLine extends StatelessWidget {
  const _MatchMetaLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Row(
      children: [
        Icon(icon, size: 12, color: c.greylight),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.appText.text12W400.copyWith(
              color: c.greyDark,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}

String _matchLocation(AllMatches match) {
  final locationName = match.locationName.trim();
  if (locationName.isNotEmpty) return locationName;
  final location = match.location.trim();
  if (location.isNotEmpty) return location;
  return 'Location TBD';
}

String _matchSchedule(AllMatches match) {
  final date = match.scheduledDate.trim();
  final time = match.scheduledTime.trim();
  if (date.isNotEmpty && time.isNotEmpty) return '$date, $time';
  if (date.isNotEmpty) return date;
  if (time.isNotEmpty) return time;
  return 'Time TBD';
}
