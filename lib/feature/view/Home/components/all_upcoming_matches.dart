import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/DeleteMAtch/delete_match_Model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/feature/view/Home/viewModel/all_upcomming_matches_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/upcoming_matches_scope.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/filter_bottom_sheet_widget_v2.dart';
import 'package:sport_finding/feature/widget/global_match_card.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';
import 'package:sport_finding/feature/webwidget/web_matches_management_widgets.dart';

class AllUpcomingMatches extends StatefulWidget {
  const AllUpcomingMatches({
    super.key,
    this.embedAsBottomTab = false,
    this.listTitle,
    this.forceMobileLayout = false,
  });

  final bool embedAsBottomTab;
  final String? listTitle;
  final bool forceMobileLayout;

  @override
  State<AllUpcomingMatches> createState() => _AllUpcomingMatchesState();
}

class _AllUpcomingMatchesState extends State<AllUpcomingMatches> {
  Future<void> _openMatchDetails(
    BuildContext context,
    AllUpcommingMatchesViewModel model,
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

  Future<void> _confirmAndDeleteMatch(
    BuildContext context,
    AllUpcommingMatchesViewModel model,
    String matchId,
    String matchTitle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppText.deleteMatchConfirmationTitle),
          content: Text(
            '${AppText.deleteMatchConfirmationMessage}\n\n“$matchTitle”',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(AppText.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: dialogContext.appColors.error,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(AppText.deleteMatch),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    final err = await model.deleteMatchById(matchId);
    if (!context.mounted) return;

    if (err == null) {
      AppSnackBar.show(
        AppText.matchDeletedSuccessfully,
        backgroundColor: context.appColors.primary,
      );
    } else {
      AppSnackBar.show(
        err,
        backgroundColor: context.appColors.error,
      );
    }
  }

  /// Same centered filter dialog as Discover web matches management.
  void _showWebMatchesFilterDialog(
    BuildContext context,
    AllUpcommingMatchesViewModel model,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
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
              initial: model.currentFilters,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AllUpcommingMatchesViewModel>(
      builder: (context, model, _) {
        if (kIsWeb && widget.embedAsBottomTab && !widget.forceMobileLayout) {
          final rows = model.matches
              .map(
                (match) => WebMatchTableRowData(
                  title: match.title,
                  sport: match.sport,
                  players:
                      '${match.currentPlayers}/${match.maxPlayers}',
                  location: match.locationName.isNotEmpty
                      ? match.locationName
                      : match.location,
                  status: _formatWebStatus(match.status),
                  onView: () => _openMatchDetails(
                    context,
                    model,
                    DiscoveryMatch.fromAllMatches(match),
                  ),
                  onEdit: () {
                    Navigator.pushNamed(
                      context,
                      RoutesName.createMatchScreen,
                      arguments: DiscoveryMatch.fromAllMatches(match),
                    );
                  },
                  onDelete:
                      model.listScope == UpcomingMatchesScope.myMatches
                      ? () => _confirmAndDeleteMatch(
                          context,
                          model,
                          match.id,
                          match.title,
                        )
                      : null,
                ),
              )
              .toList();

          IconData webEmptyIcon = Icons.search_off_rounded;
          String webEmptyLabel = AppText.noMatchesFound;
          String webEmptyDescription = AppText.matchesTrySearchOrFilters;

          if (model.isLoading) {
            webEmptyIcon = Icons.hourglass_empty_outlined;
            webEmptyLabel = 'Loading matches...';
            webEmptyDescription = '';
          } else if (model.listScope == UpcomingMatchesScope.myMatches) {
            if (model.showSearchOrFilterEmptyState) {
              webEmptyIcon = Icons.search_off_rounded;
              webEmptyLabel = AppText.noMatchesFound;
              webEmptyDescription = AppText.matchesTrySearchOrFilters;
            } else {
              webEmptyIcon = Icons.event_note_outlined;
              webEmptyLabel = AppText.noHostedMatchesYet;
              webEmptyDescription = AppText.myMatchesWebEmptySubtitle;
            }
          } else {
            if (model.showSearchOrFilterEmptyState) {
              webEmptyIcon = Icons.search_off_rounded;
              webEmptyLabel = AppText.noMatchesFound;
              webEmptyDescription = AppText.matchesTrySearchOrFilters;
            } else {
              webEmptyIcon = Icons.calendar_month_outlined;
              webEmptyLabel = AppText.noMatchesFound;
              webEmptyDescription = AppText.allUpcomingWebEmptySubtitle;
            }
          }

          return WebMatchesManagementSection(
            title: widget.listTitle ?? 'Matches Management',
            subtitle: '${rows.length} total matches',
            onSearchChanged: model.searchMatches,
            onFilterTap: () => _showWebMatchesFilterDialog(context, model),
            headerTrailing:
                model.listScope == UpcomingMatchesScope.myMatches
                    ? FilledButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, RoutesName.createMatchScreen);
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Create Match'),
                      )
                    : null,
            onSportsTap: () => _showWebMatchesFilterDialog(context, model),
            onDateTap: () => _showWebMatchesFilterDialog(context, model),
            onLocationTap: () => _showWebMatchesFilterDialog(context, model),
            rows: rows,
            emptyLabel: webEmptyLabel,
            emptyDescription: webEmptyDescription,
            emptyIcon: webEmptyIcon,
          );
        }

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
                onChanged: model.searchMatches,
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
                        initial: model.currentFilters,
                      );
                    },
                  );
                },
              ),
              SizedBox(height: context.h(16)),
              const SizedBox.shrink(),
              Expanded(
                child:
                    (!model.hasFetchedOnce && model.matches.isEmpty) ||
                        model.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : model.matches.isEmpty
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
                          return NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              final metrics = notification.metrics;
                              final shouldLoadMore =
                                  metrics.pixels >=
                                      metrics.maxScrollExtent - 200 &&
                                  model.hasNext &&
                                  !model.isLoading;
                              if (shouldLoadMore) {
                                model.loadMore();
                              }
                              return false;
                            },
                            child: ListView.separated(
                              itemCount:
                                  model.matches.length +
                                  (model.hasNext ? 1 : 0),
                              padding: context.padSym(h: 0),
                              itemBuilder: (context, index) {
                                if (index >= model.matches.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }
                                final match = model.matches[index];

                                return GlobalMatchCard.fromAllMatches(
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
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: context.h(12)),
                            ),
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

String _formatWebStatus(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return 'Pending';
  final value = trimmed.toLowerCase();
  if (value == 'open' || value == 'pending') return 'Pending';
  return '${trimmed[0].toUpperCase()}${trimmed.substring(1).toLowerCase()}';
}
