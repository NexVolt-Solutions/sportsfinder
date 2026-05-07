import 'package:flutter/material.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/feature/widget/global_match_card.dart';
 
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
