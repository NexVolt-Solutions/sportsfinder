import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/create_match_request_model.dart';
import 'package:sport_finding/Data/model/host_details_route_args.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/share_sheet_helper.dart';
import 'package:sport_finding/feature/view/Home/components/match_invite_players_screen.dart';
import 'package:sport_finding/feature/view/Home/viewModel/host_detail_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/social_button_widget.dart';

class MatchCreatedDoneScreen extends StatefulWidget {
  const MatchCreatedDoneScreen({super.key});

  @override
  State<MatchCreatedDoneScreen> createState() => _MatchCreatedDoneScreenState();
}

class _MatchCreatedDoneScreenState extends State<MatchCreatedDoneScreen> {
  Future<void> _openInvitePlayersScreen(MatchModel match) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => HostDetailScreenViewModel(),
          child: MatchInvitePlayersScreen(match: match),
        ),
      ),
    );
  }

  Future<void> _shareMatch(MatchModel match) async {
    final location =
        match.location ?? match.facilityAddress ?? match.locationName ?? '';
    final when = [match.scheduledDate ?? '', match.scheduledTime ?? '']
        .where((value) => value.isNotEmpty)
        .join(' at ');

    final shareText = [
      'Join my match on SportFinding!',
      if (match.title.isNotEmpty) match.title,
      '${match.sport} - ${match.skillLevel}',
      if (when.isNotEmpty) 'When: $when',
      if (location.isNotEmpty) 'Where: $location',
      'Players: ${match.currentPlayers ?? 0}/${match.maxPlayers ?? 0}',
    ].join('\n');

    await ShareSheetHelper.showShareSheet(
      context,
      title: match.title.isNotEmpty ? match.title : AppText.shareMatch,
      text: shareText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final match = ModalRoute.of(context)!.settings.arguments as MatchModel;

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: context.h(5),
            bottom: context.h(20),
            right: context.w(20),
            left: context.w(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SocialButtonWidget(
                imagePath: AppAssets.invitedPeopleIcon,
                text: AppText.invitePlayers,
                backgroundColor: context.appColors.primary,
                textColor: context.appColors.onPrimary,
                onTap: () => _openInvitePlayersScreen(match),
              ),
              SizedBox(height: context.h(12)),
              SocialButtonWidget(
                imagePath: AppAssets.share,
                text: AppText.shareMatch,
                onTap: () => _shareMatch(match),
              ),
              SizedBox(height: context.h(12)),
              GestureDetector(
                onTap: () {
                  final discoveryMatch = match.toDiscoveryMatch();
                  Navigator.pushNamed(
                    context,
                    RoutesName.hostDetailsScreen,
                    arguments: HostDetailsRouteArgs(
                      match: discoveryMatch,
                      popToHomeOnBack: true,
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(AppAssets.viewMatchIcon),
                    SizedBox(width: context.w(8)),
                    NormalText(
                      subText: AppText.viewMatch,
                      subColor: context.appColors.greylight,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: MainFrame(
        child: ListView(
          padding: context.padSym(h: 20),
          children: [
            AppBarWidget(
              onTapFirst: () => Navigator.pop(context),
              title: AppText.sportFinding,
            ),
            SizedBox(height: context.h(236)),
            SvgPicture.asset(
              AppAssets.matchCreatedDoneIcon,
              fit: BoxFit.scaleDown,
            ),
            NormalText(
              crossAxisAlignment: CrossAxisAlignment.center,
              titleText: AppText.matchCreated,
              subAlign: TextAlign.center,
              subText: AppText.yourMatchIsLiveShareItWithFriends,
            ),
          ],
        ),
      ),
    );
  }
}
