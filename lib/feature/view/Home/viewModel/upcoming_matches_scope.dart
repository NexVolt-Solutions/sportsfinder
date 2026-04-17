import 'package:sport_finding/Data/model/all_matches_model.dart';

/// Which subset of [DiscoveryMatchData.allMatches] a list shows.
enum UpcomingMatchesScope { allUpcoming, myMatches }

/// Route arguments for [RoutesName.allUpComingMatchesScreen].
/// When [prefetchedMatches] is non-null, the list screen uses it as the first
/// page and skips the duplicate GET /matches call (e.g. when opened from Home).
class AllUpcomingMatchesRouteArgs {
  const AllUpcomingMatchesRouteArgs({
    required this.scope,
    this.prefetchedMatches,
  });

  final UpcomingMatchesScope scope;

  /// First-page matches already loaded (e.g. from [HomeScreenViewModel]).
  final List<AllMatches>? prefetchedMatches;
}
