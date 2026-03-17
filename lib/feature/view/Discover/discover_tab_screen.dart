import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view_model/discovery_tab_view_model.dart';
import 'package:sport_finding/feature/widget/discovery_card.dart';
import 'package:sport_finding/feature/widget/discovery_search_field.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/sport_filter_section.dart';

/// Discover tab content: search, sport filters, and list of discovery match cards.
class DiscoverTabScreen extends StatelessWidget {
  const DiscoverTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiscoveryTabViewModel(),
      child: const _DiscoverTabContent(),
    );
  }
}

class _DiscoverTabContent extends StatelessWidget {
  const _DiscoverTabContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscoveryTabViewModel>(
      builder: (context, model, _) {
        return Padding(
          padding: context.padSym(h: 20, v: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(context: context),
              SizedBox(height: context.sh(20)),
              DiscoverySearchField(
                controller: model.searchController,
                hintText: AppText.searchMatchesHint,
                onChanged: (_) => model.onSearchChanged(),
                onFilterTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(AppText.filtersTitle),
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

class _Header extends StatelessWidget {
  const _Header({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NormalText(
                titleText: AppText.appName,
                titleStyle: this.context.appText.text14W500,
                titleColor: this.context.appColors.greyDark,
              ),
              SizedBox(height: this.context.sh(4)),
              NormalText(
                titleText: AppText.discoverTitle,
                titleStyle: this.context.appText.text18W600,
                titleColor: this.context.appColors.onSurface,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppText.notificationsTitle),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: SvgPicture.asset(
            AppAssets.notificationIcon,
            width: context.sw(24),
            height: context.sw(24),
            colorFilter: ColorFilter.mode(
              context.appColors.greyDark,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
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
      separatorBuilder: (_, __) => SizedBox(height: context.sh(16)),
      itemBuilder: (context, index) {
        final match = matches[index];
        return DiscoveryCard(
          match: match,
          onSeeAllTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${AppText.discoverSeeAll}: ${match.title}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }
}
