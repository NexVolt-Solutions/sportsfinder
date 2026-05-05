import 'package:sport_finding/Data/model/discovery_match.dart';

class HostDetailsRouteArgs {
  const HostDetailsRouteArgs({
    required this.match,
    this.popToHomeOnBack = false,
  });

  final DiscoveryMatch match;
  final bool popToHomeOnBack;
}
