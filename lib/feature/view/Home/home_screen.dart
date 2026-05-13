import 'package:flutter/foundation.dart';
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
import 'package:sport_finding/Data/model/sport.dart';
import 'package:sport_finding/feature/widget/card_icon_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/global_match_card.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';
import 'package:sport_finding/feature/widget/section_header_widget.dart';
import 'package:sport_finding/feature/widget/shimmer_loading.dart';
import 'package:sport_finding/feature/widget/user_greeting_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, });

 

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSelected = false;
  static const int _sportsPreviewLimit = 8;
  String? _selectedSportCategory;
  String _sportsQuery = '';

  List<String> _sportCategories(HomeScreenViewModel model) {
    final categories = model.sports
        .map((s) => (s.category ?? '').trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return categories;
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

  List<Sport> _filteredSports(HomeScreenViewModel model) {
    final q = _sportsQuery.trim().toLowerCase();
    final base = _selectedSportCategory == null
        ? model.sports
        : model.sports.where((s) {
            return (s.category ?? '').trim() == _selectedSportCategory;
          }).toList();
    if (q.isEmpty) return base;
    return base.where((s) {
      final title = s.title.toLowerCase();
      final id = (s.id ?? '').toLowerCase();
      final category = (s.category ?? '').toLowerCase();
      return title.contains(q) || id.contains(q) || category.contains(q);
    }).toList();
  }

  List<Sport> _previewSports(HomeScreenViewModel model) {
    final list = List<Sport>.from(_filteredSports(model));
    list.sort((a, b) {
      final ap = a.isPopular == true;
      final bp = b.isPopular == true;
      if (ap != bp) return ap ? -1 : 1;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return list.take(_sportsPreviewLimit).toList();
  }

  int _hiddenSportsCount(HomeScreenViewModel model) {
    final total = _filteredSports(model).length;
    return total > _sportsPreviewLimit ? total - _sportsPreviewLimit : 0;
  }

  void _openSportsCatalog(HomeScreenViewModel model) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _MobileSportsCatalogSheet(
          sports: model.sports,
          initialCategory: _selectedSportCategory,
          initialQuery: _sportsQuery,
          onChanged: (category, query) {
            setState(() {
              _selectedSportCategory = category;
              _sportsQuery = query;
            });
          },
        );
      },
    );
  }

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
        return ListView(
          padding: context.padSym(h: 20, v: 20),
          children: [
            // if (widget.showAppBar) ...[
            //   AppBarWidget(
            //     leading: NormalText(
            //       titleText: AppText.sportFinding,
            //       titleFontSize: 18,
            //     ),
            //   ),
            // ],
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
            SizedBox(height: context.h(14)),
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

            SizedBox(height: context.h(14)),
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
            model.matchesLoading
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
                     return SizedBox(
                       height: kIsWeb?260:180,
                       child: ListView.separated(
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
                       ),
                     );
                   },
                 ),
          
                      SizedBox(height: context.h(8)),

            SectionHeaderWidget(title: AppText.popularSports),
            SizedBox(height: context.h(8)),
            if (_sportCategories(model).isNotEmpty) ...[
              SizedBox(
                height: context.h(40),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _SportCategoryChipMobile(
                      label: 'All',
                      isSelected: _selectedSportCategory == null,
                      onTap: () => setState(() => _selectedSportCategory = null),
                    ),
                    for (final category in _sportCategories(model)) ...[
                      SizedBox(width: context.w(8)),
                      _SportCategoryChipMobile(
                        label: _formatCategoryLabel(category),
                        isSelected: _selectedSportCategory == category,
                        onTap: () =>
                            setState(() => _selectedSportCategory = category),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: context.h(12)),
            ],
            Wrap(
              spacing: context.w(12),
              runSpacing: context.h(12),
              children: [
                for (final sport in _previewSports(model))
                  SizedBox(
                    width: (MediaQuery.of(context).size.width -
                            context.w(20) * 2 -
                            context.w(12)) /
                        2,
                    child: CardWidget(
                      padding: context.padSym(h: 16, v: 14),
                      child: Row(
                        children: [
                          CardIconWidget(
                            imageAsset: sport.imagePath,
                            padding: 8,
                            iconSize: context.w(18),
                            borderRadius: context.radius(12),
                          ),
                          SizedBox(width: context.w(10)),
                          Expanded(
                            child: Text(
                              sport.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.appText.text14W600.copyWith(
                                color: context.appColors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_hiddenSportsCount(model) > 0)
                  SizedBox(
                    width: (MediaQuery.of(context).size.width -
                            context.w(20) * 2 -
                            context.w(12)) /
                        2,
                    child: CardWidget(
                      onTap: () => _openSportsCatalog(model),
                      padding: context.padSym(h: 16, v: 14),
                      child: Row(
                        children: [
                          Icon(
                            Icons.more_horiz_rounded,
                            color: context.appColors.primary,
                          ),
                          SizedBox(width: context.w(10)),
                          Expanded(
                            child: Text(
                              '+${_hiddenSportsCount(model)} more',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.appText.text14W600.copyWith(
                                color: context.appColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SportCategoryChipMobile extends StatelessWidget {
  const _SportCategoryChipMobile({
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
          color: isSelected ? c.primary : c.blue10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? c.primary : c.greylight.withValues(alpha: 0.45),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appText.text12W600.copyWith(
            color: isSelected ? c.onPrimary : c.greyDark,
          ),
        ),
      ),
    );
  }
}

class _MobileSportsCatalogSheet extends StatefulWidget {
  const _MobileSportsCatalogSheet({
    required this.sports,
    required this.initialCategory,
    required this.initialQuery,
    required this.onChanged,
  });

  final List<Sport> sports;
  final String? initialCategory;
  final String initialQuery;
  final void Function(String? category, String query) onChanged;

  @override
  State<_MobileSportsCatalogSheet> createState() =>
      _MobileSportsCatalogSheetState();
}

class _MobileSportsCatalogSheetState extends State<_MobileSportsCatalogSheet> {
  late String? _category = widget.initialCategory;
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialQuery);

  List<String> get _categories {
    final list = widget.sports
        .map((s) => (s.category ?? '').trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return list;
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

  List<Sport> get _visibleSports {
    final q = _controller.text.trim().toLowerCase();
    return widget.sports.where((s) {
      final category = (s.category ?? '').trim();
      if (_category != null && category != _category) return false;
      if (q.isEmpty) return true;
      return s.title.toLowerCase().contains(q) ||
          (s.id ?? '').toLowerCase().contains(q) ||
          category.toLowerCase().contains(q);
    }).toList();
  }

  void _emit() => widget.onChanged(_category, _controller.text);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final sports = _visibleSports;
    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: c.onPrimary,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.radius(18)),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: context.h(10)),
              Container(
                width: context.w(44),
                height: context.h(4),
                decoration: BoxDecoration(
                  color: c.greylight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: context.padSym(h: 16, v: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Sports',
                        style: context.appText.text16W600.copyWith(
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
              ),
              Padding(
                padding: context.padSym(h: 16),
                child: TextField(
                  controller: _controller,
                  onChanged: (_) => setState(_emit),
                  decoration: InputDecoration(
                    hintText: 'Search sports...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: c.blue10,
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
              ),
              SizedBox(height: context.h(12)),
              SizedBox(
                height: context.h(44),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: context.padSym(h: 16),
                  children: [
                    _SportCategoryChipMobile(
                      label: 'All',
                      isSelected: _category == null,
                      onTap: () => setState(() {
                        _category = null;
                        _emit();
                      }),
                    ),
                    for (final cat in _categories) ...[
                      SizedBox(width: context.w(8)),
                      _SportCategoryChipMobile(
                        label: _formatCategoryLabel(cat),
                        isSelected: _category == cat,
                        onTap: () => setState(() {
                          _category = cat;
                          _emit();
                        }),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: context.h(12)),
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
                        controller: scrollController,
                        padding: context.padSym(h: 16, v: 10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: sports.length,
                        itemBuilder: (context, index) {
                          final sport = sports[index];
                          return CardWidget(
                            padding: context.padSym(h: 12, v: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CardIconWidget(
                                  imageAsset: sport.imagePath,
                                  padding: 8,
                                  iconSize: context.w(18),
                                  borderRadius: context.radius(12),
                                ),
                                SizedBox(height: context.h(8)),
                                Text(
                                  sport.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
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
        );
      },
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
    return SizedBox(
      height: GlobalMatchCard.listSlotHeight(context),
      child: ListView.separated(
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight <= 150;
                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          ShimmerBox(width: 120, height: 14),
                          ShimmerBox(width: 90, height: 10),
                          ShimmerBox(width: 150, height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ShimmerBox(width: 60, height: 10),
                              ShimmerBox(
                                width: 28,
                                height: 28,
                                shape: BoxShape.circle,
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    return Column(
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
                            ShimmerBox(
                              width: 44,
                              height: 44,
                              shape: BoxShape.circle,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
