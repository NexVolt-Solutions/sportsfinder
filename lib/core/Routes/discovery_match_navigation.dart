import 'package:flutter/material.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/model/discovery_match.dart';

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
    Navigator.pushNamed(
      context,
      RoutesName.hostDetailsScreen,
      arguments: this,
    );
  }
}
