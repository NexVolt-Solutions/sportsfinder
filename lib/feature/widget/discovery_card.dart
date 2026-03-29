import 'package:flutter/material.dart';
import 'package:sport_finding/feature/model/discovery_match.dart';
import 'package:sport_finding/feature/widget/global_match_card.dart';

/// Match list row for a [DiscoveryMatch]. Delegates to [GlobalMatchCard] so
/// Discover shares the same layout as Home / All Upcoming; change styling in
/// [GlobalMatchCard] only.
class DiscoveryCard extends StatelessWidget {
  const DiscoveryCard({
    super.key,
    required this.match,
    this.onSeeAllTap,
    this.onCardTap,
  });

  final DiscoveryMatch match;
  final VoidCallback? onSeeAllTap;
  final VoidCallback? onCardTap;

  @override
  Widget build(BuildContext context) {
    return GlobalMatchCard.fromDiscovery(
      match,
      onCardTap: onCardTap,
      onSeeAllTap: onSeeAllTap,
    );
  }
}
