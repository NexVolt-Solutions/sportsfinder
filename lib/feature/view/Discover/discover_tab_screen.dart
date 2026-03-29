import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Discover/viewModel/discovery_tab_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/discovery_card.dart';
import 'package:sport_finding/feature/widget/discovery_search_field.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/sport_filter_section.dart';

/// Discover tab content: search, sport filters, and list of discovery match cards.
class DiscoverTabScreen extends StatelessWidget {
  const DiscoverTabScreen({super.key, this.embedInBottomBar = false});

  /// When true, [BottomBarScreen] supplies the shared [AppBarWidget].
  final bool embedInBottomBar;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiscoveryTabViewModel(),
      child: _DiscoverTabContent(embedInBottomBar: embedInBottomBar),
    );
  }
}

class _DiscoverTabContent extends StatelessWidget {
  const _DiscoverTabContent({required this.embedInBottomBar});

  final bool embedInBottomBar;

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscoveryTabViewModel>(
      builder: (context, model, _) {
        return Padding(
          padding: context.padSym(h: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!embedInBottomBar) ...[
                AppBarWidget(
                  onTapFirst: () => Navigator.pop(context),
                  leading: NormalText(titleText: AppText.sportFinding),
                  trailing: SvgPicture.asset(AppAssets.notificationIcon),
                ),
              ],
              NormalText(titleText: AppText.discover),
              SizedBox(height: context.sh(20)),
              DiscoverySearchField(
                controller: model.searchController,
                hintText: AppText.searchMatches,
                onChanged: (_) => model.onSearchChanged(),
                onFilterTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(AppText.searchMatches),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              SizedBox(height: context.sh(24)),
              SportFilterSection(
                chips: model.filterChips,
                selectedIndex: model.selectedFilterIndex,
                onSelected: model.setSelectedFilterIndex,
              ),
              SizedBox(height: context.sh(20)),
              Expanded(child: _MatchesList(model: model)),
            ],
          ),
        );
      },
    );
  }
}

class _MatchesList extends StatelessWidget {
  const _MatchesList({required this.model});

  final DiscoveryTabViewModel model;

  @override
  Widget build(BuildContext context) {
    final matches = model.filteredMatches;
    if (matches.isEmpty) {
      return Center(
        child: Text(
          'No matches found',
          style: context.appText.text14W400.copyWith(
            color: context.appColors.greyDark,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: matches.length,
      separatorBuilder: (_, _) => SizedBox(height: context.sh(16)),
      itemBuilder: (context, index) {
        final match = matches[index];
        return DiscoveryCard(
          match: match,
          onSeeAllTap: () {
            Navigator.pushNamed(
              context,
              RoutesName.seeAllInvatedPlayerScreen,
              arguments: match,
            );
          },
        );
      },
    );
  }
}
