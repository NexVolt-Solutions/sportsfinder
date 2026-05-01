import 'package:sport_finding/Data/model/all_matches_model.dart';

 enum UpcomingMatchesScope { allUpcoming, myMatches }

 class AllUpcomingMatchesRouteArgs {
  const AllUpcomingMatchesRouteArgs({
    required this.scope,
    this.prefetchedMatches,
    this.hasNext,
  });

  final UpcomingMatchesScope scope;

  final List<AllMatches>? prefetchedMatches;
  final bool? hasNext;
}
