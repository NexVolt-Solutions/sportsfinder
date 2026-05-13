import 'package:flutter/material.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/Data/model/public_profile_args.dart';

extension DiscoveryMatchNavigation on DiscoveryMatch {
  /// Hosted by the current user → [HostDetailsScreen]; otherwise → [UserMatchDetailsScreen].
  void pushMatchOrHostScreen(BuildContext context) {
    if (isHostedByCurrentUser) {
      pushHostDetailsScreen(context);
    } else {
      pushUserMatchDetailsScreen(context);
    }
  }

  /// Always opens [UserMatchDetailsScreen] (e.g. from host tools to preview the public match view).
  void pushUserMatchDetailsScreen(BuildContext context) {
    Navigator.pushNamed(
      context,
      RoutesName.userMatchDetailsScreen,
      arguments: this,
    );
  }

  /// Always opens [HostDetailsScreen] (e.g. “host dashboard” from match detail).
  void pushHostDetailsScreen(BuildContext context) {
    Navigator.pushNamed(context, RoutesName.hostDetailsScreen, arguments: this);
  }

  /// Opens [PublicProfileScreen] using a real user id from [GET /api/v1/users].
  void pushPublicProfileForUser(
    BuildContext context, {
    required String userId,
    required String displayName,
  }) {
    final uid = userId.trim();
    final name = displayName.trim();
    if (uid.isEmpty || name.isEmpty) return;
    Navigator.pushNamed(
      context,
      RoutesName.publicProfileScreen,
      arguments: PublicProfileArgs(
        userId: uid,
        displayName: name,
        canRateForMatch: !isUpcomingRelativeTo(DateTime.now()),
      ),
    );
  }
}
