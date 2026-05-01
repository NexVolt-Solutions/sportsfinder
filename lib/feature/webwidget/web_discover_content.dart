import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view/Discover/viewModel/discovery_tab_view_model.dart';
import 'package:sport_finding/feature/widget/discovery_search_field.dart';
import 'package:sport_finding/feature/widget/filter_bottom_sheet_widget_v2.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/webwidget/web_dashboard_widgets.dart';

class WebDiscoverContent extends StatelessWidget {
  const WebDiscoverContent({
    super.key,
    required this.model,
    required this.matchesList,
  });

  final DiscoveryTabViewModel model;
  final Widget matchesList;

  @override
  Widget build(BuildContext context) {
    return MainFrame(
      showDecorationLayer: false,
      child: Padding(
        padding: context.padSym(h: 20, v: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WebDashboardTitle(
              title: 'Discover Matches',
              subtitle: 'Explore sports, players, and nearby games.',
            ),
            SizedBox(height: context.sh(20)),
            Expanded(
              child: WebDashboardPanel(
                padding: context.padSym(h: 18, v: 18),
                child: Column(
                  children: [
                    DiscoverySearchField(
                      controller: model.searchController,
                      hintText: AppText.searchMatches,
                      onChanged: (_) => model.onSearchChanged(),
                      onFilterTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return FilterBottomSheet(
                              onApply: model.applyFilters,
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: context.sh(20)),
                    Expanded(child: matchesList),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
