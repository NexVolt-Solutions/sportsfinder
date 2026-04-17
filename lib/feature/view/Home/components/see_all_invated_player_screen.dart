import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/all_matches_model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/Data/model/public_profile_args.dart';
import 'package:sport_finding/feature/view/Home/viewModel/see_all_invated_player_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/person_invited_card.dart';

/// Route arguments: [AllMatches] (All Upcoming) or [DiscoveryMatch] (Discover).
/// Never cast with `as`; use pattern matching only.
class SeeAllInvatedPlayerScreen extends StatelessWidget {
  const SeeAllInvatedPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final raw = ModalRoute.of(context)?.settings.arguments;
    final labels = _labelsForRouteArgs(raw);
    final matchId = _matchIdForRouteArgs(raw);

    return Consumer<SeeAllInvatedPlayerScreenViewModel>(
      builder: (context, model, _) => Scaffold(
        body: MainFrame(
          child: Padding(
            padding: context.padSym(h: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.h(20)),
                AppBarWidget(
                  onTapFirst: () => Navigator.pop(context),
                  title: AppText.sportFinding,
                ),
                SizedBox(height: context.h(20)),
                NormalText(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  titleText: AppText.participatedPlayers,
                  titleStyle: context.appText.text16W500,
                  titleColor: context.appColors.surface,
                ),
                SizedBox(height: context.h(8)),
                if (model.isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (model.error != null)
                  Expanded(
                    child: Center(
                      child: Text(
                        model.error!,
                        textAlign: TextAlign.center,
                        style: context.appText.text14W400.copyWith(
                          color: context.appColors.greyDark,
                        ),
                      ),
                    ),
                  )
                else if (model.joinedPlayers.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        AppText.noPlayersOnRoster,
                        style: context.appText.text14W400.copyWith(
                          color: context.appColors.greyDark,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: model.joinedPlayers.length,
                      separatorBuilder: (_, i) =>
                          SizedBox(height: context.h(10)),
                      itemBuilder: (context, index) {
                        final row = model.joinedPlayers[index];
                        final name = row.user.fullName;
                        return PersonInvitedCard(
                          ontap: () {},
                          cardOnTap: () {
                            Navigator.pushNamed(
                              context,
                              RoutesName.publicProfileScreen,
                              arguments: PublicProfileArgs(
                                userId: row.user.id,
                                displayName: name,
                                initialMatchId: matchId,
                              ),
                            );
                          },
                          playerName: name,
                          matchLevel: labels.skill,
                          matchName: labels.sport,
                          destance: labels.distance,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _matchIdForRouteArgs(Object? raw) {
  return switch (raw) {
    AllMatches m => m.id,
    DiscoveryMatch m => m.id,
    _ => null,
  };
}

class _CardLabels {
  const _CardLabels({
    required this.sport,
    required this.distance,
    required this.skill,
  });

  final String sport;
  final String distance;
  final String skill;
}

_CardLabels _labelsForRouteArgs(Object? raw) {
  return switch (raw) {
    AllMatches m => _CardLabels(
      sport: m.sport,
      distance: _formatKm(m.distanceKm),
      skill: m.skillLevel,
    ),
    DiscoveryMatch m => _CardLabels(
      sport: m.sportType,
      distance: _formatKm(m.distanceKm),
      skill: m.skillLevel,
    ),
    _ => const _CardLabels(sport: '', distance: '—', skill: ''),
  };
}

String _formatKm(double? km) {
  if (km == null) return '—';
  return '${km.toStringAsFixed(1)} km';
}
