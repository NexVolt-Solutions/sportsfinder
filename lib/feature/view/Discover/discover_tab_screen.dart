import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Network/notification_service.dart';
import 'package:sport_finding/core/Routes/discovery_match_navigation.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/view/Discover/viewModel/discovery_tab_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/discovery_card.dart';
import 'package:sport_finding/feature/widget/filter_bottom_sheet_widget_v2.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';
import 'package:sport_finding/feature/webwidget/web_matches_management_widgets.dart';

class DiscoverTabScreen extends StatelessWidget {
  const DiscoverTabScreen({
    super.key,
    this.embedInBottomBar = false,
    this.forceMobileLayout = false,
  });

  final bool embedInBottomBar;
  final bool forceMobileLayout;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiscoveryTabViewModel(),
      child: _DiscoverTabContent(
        embedInBottomBar: embedInBottomBar,
        forceMobileLayout: forceMobileLayout,
      ),
    );
  }
}

class _DiscoverTabContent extends StatefulWidget {
  const _DiscoverTabContent({
    required this.embedInBottomBar,
    required this.forceMobileLayout,
  });

  final bool embedInBottomBar;
  final bool forceMobileLayout;

  @override
  State<_DiscoverTabContent> createState() => _DiscoverTabContentState();
}

class _DiscoverTabContentState extends State<_DiscoverTabContent> {
  static const int _discoverTabIndex = 1;
  bool _wasActiveBottomBarTab = false;

  Widget _buildNotificationBell(BuildContext context) {
    final c = context.appColors;
    final unreadCount = context.select<NotificationService, int>(
      (service) => service.unreadCount,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SvgPicture.asset(AppAssets.notificationIcon),
        if (unreadCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: c.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                textAlign: TextAlign.center,
                style: context.appText.text12W500.copyWith(
                  color: c.onPrimary,
                  fontSize: 9,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscoveryTabViewModel>(
      builder: (context, model, _) {
        final selectedIndex = widget.embedInBottomBar
            ? context.select<BottomBarScreenViewModel, int>(
                (vm) => vm.selectedIndex,
              )
            : null;
        final isActiveTab = selectedIndex == _discoverTabIndex;
        if (!widget.embedInBottomBar || isActiveTab) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            model.ensureLoaded();
          });
        }
        if (widget.embedInBottomBar && _wasActiveBottomBarTab && !isActiveTab) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            model.searchController.clear();
            model.onSearchChanged();
          });
        }
        if (widget.embedInBottomBar) {
          _wasActiveBottomBarTab = isActiveTab;
        }

        final notificationService = context.watch<NotificationService>();
        if (kIsWeb && !widget.forceMobileLayout) {
          final rows = model.filteredMatches
              .map(
                (match) => WebMatchTableRowData(
                  title: match.title,
                  sport: match.sportType,
                  players: match.participantsLabel,
                  location: match.location,
                  status: _formatStatus(match.status),
                  onView: () => match.pushMatchOrHostScreen(context),
                ),
              )
              .toList();
          return WebMatchesManagementSection(
            title: 'Matches Management',
            subtitle: '${rows.length} total matches',
            onSearchChanged: (value) {
              model.searchController.text = value;
              model.onSearchChanged();
            },
            onFilterTap: () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return Dialog(
                    insetPadding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 48,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 520,
                        maxHeight: 640,
                      ),
                      child: FilterBottomSheet(
                        onApply: model.applyFilters,
                        asDialog: true,
                      ),
                    ),
                  );
                },
              );
            },
            onSportsTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return FilterBottomSheet(onApply: model.applyFilters);
                },
              );
            },
            onDateTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return FilterBottomSheet(onApply: model.applyFilters);
                },
              );
            },
            onLocationTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return FilterBottomSheet(onApply: model.applyFilters);
                },
              );
            },
            rows: rows,
            emptyLabel: model.isLoading
                ? 'Loading matches...'
                : (model.error ?? AppText.noMatchesFound),
          );
        }
        return Padding(
          padding: context.padSym(h: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.embedInBottomBar) ...[
                AppBarWidget(
                  onTapFirst: () => Navigator.pop(context),
                  leading: NormalText(titleText: AppText.sportFinding),
                  trailing: _buildNotificationBell(context),
                  onTrailingTap: () async {
                    await notificationService.fetchNotifications();
                    if (!context.mounted) return;
                    Navigator.pushNamed(
                      context,
                      RoutesName.notificationsScreen,
                    );
                  },
                ),
              ],
              NormalText(titleText: AppText.discover),
              SizedBox(height: context.sh(20)),
              SearchBarWidget(
                controller: model.searchController,
                hintText: AppText.searchMatches,
                isShow: true,
                onChanged: (value) {
                  model.onSearchChanged();
                },
                onFilterTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return FilterBottomSheet(onApply: model.applyFilters);
                    },
                  );
                },
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

String _formatStatus(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return 'Pending';
  final value = trimmed.toLowerCase();
  if (value == 'open' || value == 'pending') return 'Pending';
  return '${trimmed[0].toUpperCase()}${trimmed.substring(1).toLowerCase()}';
}

class _MatchesList extends StatelessWidget {
  const _MatchesList({required this.model});

  final DiscoveryTabViewModel model;

  @override
  Widget build(BuildContext context) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (model.error != null) {
      return Center(
        child: Padding(
          padding: context.padSym(h: 16),
          child: Text(
            model.error!,
            textAlign: TextAlign.center,
            style: context.appText.text14W400.copyWith(
              color: context.appColors.greyDark,
            ),
          ),
        ),
      );
    }

    final matches = model.filteredMatches;
    if (matches.isEmpty) {
      return Center(
        child: Text(
          AppText.noMatchesFound,
          style: context.appText.text14W400.copyWith(
            color: context.appColors.greyDark,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: matches.length,
      separatorBuilder: (_, _) => SizedBox(height: context.sh(0)),
      itemBuilder: (context, index) {
        final match = matches[index];
        return Padding(
          padding: context.padSym(v: 6),
          child: DiscoveryCard(
            match: match,
            onCardTap: () => match.pushMatchOrHostScreen(context),
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
    );
  }
}
