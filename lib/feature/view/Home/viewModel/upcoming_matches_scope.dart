/// Which subset of [DiscoveryMatchData.allMatches] a list shows.
enum UpcomingMatchesScope {
  /// Matches scheduled after [DateTime.now()], **you host or not** — "All Upcoming".
  allUpcoming,

  /// Matches **you host only** — **My Matches** tab (past and future).
  myMatches,
}
