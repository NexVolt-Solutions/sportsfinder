import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/all_matches_model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/Data/model/sport.dart';
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

class WebHomeContent extends StatefulWidget {
  const WebHomeContent({super.key, required this.model});

  final HomeScreenViewModel model;

  @override
  State<WebHomeContent> createState() => _WebHomeContentState();
}

class _WebHomeContentState extends State<WebHomeContent> {
  static const int _previewLimit = 8;

  String? _selectedCategory;

  HomeScreenViewModel get model => widget.model;

  List<Sport> get _filteredSportsForCatalog {
    if (_selectedCategory == null) return model.sports;
    return model.sports.where((sport) {
      return (sport.category?.trim() ?? '') == _selectedCategory;
    }).toList();
  }

  List<Sport> get _previewSourceSports {
    final filtered = _filteredSportsForCatalog;
    filtered.sort((a, b) {
      final ap = a.isPopular == true;
      final bp = b.isPopular == true;
      if (ap != bp) return ap ? -1 : 1;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return filtered;
  }

  List<String> get _categories {
    final categories =
        model.sports
            .map((sport) => sport.category?.trim() ?? '')
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return categories;
  }

  List<Sport> get _visibleSports {
    return _previewSourceSports.take(_previewLimit).toList();
  }

  int get _hiddenSportsCount {
    final total = _previewSourceSports.length;
    return total > _previewLimit ? total - _previewLimit : 0;
  }

  void _selectCategory(String? category) {
    setState(() => _selectedCategory = category);
  }

  void _openSportsCatalog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return _SportsCatalogDialog(
          sports: model.sports,
          initialCategory: _selectedCategory,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleSports = _visibleSports;

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
          height: 170,
          child: model.matchesLoading
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 2,
                  itemBuilder: (context, _) {
                    return SizedBox(
                      width: context.w(162),
                      child: WebDashboardPanel(
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
                      width: context.w(229),
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
        WebDashboardTitle(
          title: 'Sports Categories',
          subtitle: _selectedCategory == null
              ? 'All sports'
              : _formatCategoryLabel(_selectedCategory!),
          trailing: _hiddenSportsCount > 0
              ? GestureDetector(
                  onTap: _openSportsCatalog,
                  child: Text(
                    'View All',
                    style: context.appText.text12W500.copyWith(
                      color: context.appColors.primary,
                    ),
                  ),
                )
              : null,
        ),
        SizedBox(height: context.h(12)),
        if (_categories.isNotEmpty) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SportCategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () => _selectCategory(null),
                ),
                for (final category in _categories) ...[
                  SizedBox(width: context.w(8)),
                  _SportCategoryChip(
                    label: _formatCategoryLabel(category),
                    isSelected: _selectedCategory == category,
                    onTap: () => _selectCategory(category),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: context.h(14)),
        ],
        Wrap(
          spacing: context.w(14),
          runSpacing: context.h(14),
          children: [
            ...visibleSports.map((sport) {
              return SizedBox(
                width: context.w(108),
                height: 108,
                child: WebDashboardPanel(
                  padding: context.padSym(h: 12, v: 12),
                  backgroundColor: const Color(0xFFEAF6FF),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CardIconWidget(
                        imageAsset: sport.imagePath,
                        padding: 8,
                        iconSize: context.w(18),
                        borderRadius: context.radius(12),
                      ),
                      SizedBox(height: context.h(6)),
                      Text(
                        sport.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.appText.text12W600.copyWith(
                          color: context.appColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (_hiddenSportsCount > 0)
              _ViewMoreSportsCard(
                count: _hiddenSportsCount,
                onTap: _openSportsCatalog,
              ),
          ],
        ),
      ],
    );
  }
}

class _SportCategoryChip extends StatelessWidget {
  const _SportCategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? c.primary : const Color(0xFFEAF6FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? c.primary : const Color(0xFFD7E7F7),
          ),
        ),
        child: Text(
          label,
          style: context.appText.text12W600.copyWith(
            color: isSelected ? c.onPrimary : c.greyDark,
          ),
        ),
      ),
    );
  }
}

class _ViewMoreSportsCard extends StatelessWidget {
  const _ViewMoreSportsCard({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.w(108),
      height: 108,
      child: GestureDetector(
        onTap: onTap,
        child: WebDashboardPanel(
          padding: context.padSym(h: 12, v: 12),
          backgroundColor: const Color(0xFFEAF6FF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.more_horiz_rounded,
                color: context.appColors.primary,
                size: 28,
              ),
              SizedBox(height: context.h(6)),
              Text(
                '+$count more',
                textAlign: TextAlign.center,
                style: context.appText.text12W600.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.appColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportsCatalogDialog extends StatefulWidget {
  const _SportsCatalogDialog({
    required this.sports,
    required this.initialCategory,
  });

  final List<Sport> sports;
  final String? initialCategory;

  @override
  State<_SportsCatalogDialog> createState() => _SportsCatalogDialogState();
}

class _SportsCatalogDialogState extends State<_SportsCatalogDialog> {
  String? _category;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  List<String> get _categories {
    final categories =
        widget.sports
            .map((sport) => sport.category?.trim() ?? '')
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return categories;
  }

  List<Sport> get _visibleSports {
    return widget.sports.where((sport) {
      final category = sport.category?.trim() ?? '';
      if (_category != null && category != _category) return false;
      if (_query.isEmpty) return true;
      return sport.title.toLowerCase().contains(_query) ||
          (sport.id ?? '').toLowerCase().contains(_query) ||
          category.toLowerCase().contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final sports = _visibleSports;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sports Catalog',
                      style: context.appText.text18Bold.copyWith(
                        color: c.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  setState(() => _query = value.trim().toLowerCase());
                },
                decoration: InputDecoration(
                  hintText: 'Search sports...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: const Color(0xFFEAF6FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: c.greylight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: c.greylight),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _SportCategoryChip(
                      label: 'All',
                      isSelected: _category == null,
                      onTap: () => setState(() => _category = null),
                    ),
                    for (final category in _categories) ...[
                      const SizedBox(width: 8),
                      _SportCategoryChip(
                        label: _formatCategoryLabel(category),
                        isSelected: _category == category,
                        onTap: () => setState(() => _category = category),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: sports.isEmpty
                    ? Center(
                        child: Text(
                          'No sports found',
                          style: context.appText.text14W500.copyWith(
                            color: c.greyDark,
                          ),
                        ),
                      )
                    : GridView.builder(
                        itemCount: sports.length,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 132,
                              mainAxisExtent: 112,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                        itemBuilder: (context, index) {
                          final sport = sports[index];
                          return WebDashboardPanel(
                            padding: context.padSym(h: 12, v: 12),
                            backgroundColor: const Color(0xFFEAF6FF),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CardIconWidget(
                                  imageAsset: sport.imagePath,
                                  padding: 8,
                                  iconSize: context.w(18),
                                  borderRadius: context.radius(12),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  sport.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.appText.text12W600.copyWith(
                                    color: c.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatCategoryLabel(String category) {
  return category
      .split('_')
      .where((part) => part.trim().isNotEmpty)
      .map((part) {
        final lower = part.toLowerCase();
        return '${lower[0].toUpperCase()}${lower.substring(1)}';
      })
      .join(' ');
}

class _WebHomeMatchCard extends StatelessWidget {
  const _WebHomeMatchCard({required this.match, required this.onTap});

  final AllMatches match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return InkWell(
      focusColor: context.appColors.transparent,
      hoverColor: context.appColors.transparent,
      highlightColor: context.appColors.transparent,
      splashColor: context.appColors.transparent,
      borderRadius: BorderRadius.circular(context.radius(12)),
      onTap: onTap,
      child: WebDashboardPanel(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: NormalText(
                    titleText: match.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            NormalText(
              titleText: match.sport,
              titleColor: c.greyDark,
              titleStyle: context.appText.text12W400,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.group_rounded, size: 24, color: c.primary),
                const SizedBox(width: 4),
                NormalText(
                  titleText: '${match.currentPlayers}/${match.maxPlayers}',
                  titleColor: c.greyDark,
                  titleStyle: context.appText.text12W600,
                ),
              ],
            ),
          ],
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
