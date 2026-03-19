import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/model/discovery_match.dart';
import 'package:sport_finding/feature/view_model/see_all_invated_player_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/person_invited_card.dart';

class SeeAllInvatedPlayerScreen extends StatefulWidget {
  const SeeAllInvatedPlayerScreen({super.key});

  @override
  State<SeeAllInvatedPlayerScreen> createState() =>
      _SeeAllInvatedPlayerScreenState();
}

class _SeeAllInvatedPlayerScreenState extends State<SeeAllInvatedPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    // ✅ CAST TO CORRECT MODEL
    final match = ModalRoute.of(context)!.settings.arguments as DiscoveryMatch;

    return Consumer<SeeAllInvatedPlayerScreenViewModel>(
      builder: (context, model, child) => Scaffold(
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
                  titleText: AppText.invitationSent,
                  titleStyle: context.appText.text16W500,
                  titleColor: context.appColors.surface,
                ),

                SizedBox(height: context.h(8)),

                SizedBox(
                  height: context.h(200),
                  child: ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return PersonInvitedCard(
                        cardOnTap: () {
                          print("Clicked Match ID: ${match.id}");
                        },
                        playerName: match.title,
                        matchLevel: AppText.advanced,
                        matchName: match.sportType,
                        destance: "${match.distanceKm} km",
                        ontap: () {
                          Navigator.pushNamed(
                            context,
                            RoutesName.PlayerMatchDetailsScreen,
                            arguments: match,
                          );
                        },
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
