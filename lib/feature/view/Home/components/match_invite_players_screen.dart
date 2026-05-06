import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/create_match_request_model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Network/list_of_all_user_service.dart';
import 'package:sport_finding/core/Routes/discovery_match_navigation.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/feature/view/Home/viewModel/host_detail_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/person_invited_card.dart';
 
class MatchInvitePlayersScreen extends StatefulWidget {
  const MatchInvitePlayersScreen({super.key, required this.match});

  final MatchModel match;

  @override
  State<MatchInvitePlayersScreen> createState() =>
      _MatchInvitePlayersScreenState();
}

class _MatchInvitePlayersScreenState extends State<MatchInvitePlayersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final model = context.read<HostDetailScreenViewModel>();
      model.bindMatch(widget.match.toDiscoveryMatch());
      model.ensureUsersLoadedForPlayersTab();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HostDetailScreenViewModel>(
      builder: (context, model, _) {
        final match = model.currentMatch ?? widget.match.toDiscoveryMatch();

        return Scaffold(
          body: MainFrame(
            child: Padding(
              padding: context.padSym(h: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppBarWidget(
                    onTapFirst: () => Navigator.pop(context),
                    title: AppText.invitePlayers,
                  ),
                  Text(
                    widget.match.title,
                    style: context.appText.text18Bold.copyWith(
                      color: context.appColors.onSurface,
                    ),
                  ),
                  SizedBox(height: context.h(4)),
                  Text(
                    '${widget.match.sport} - ${widget.match.skillLevel}',
                    style: context.appText.text14W400.copyWith(
                      color: context.appColors.greylight,
                    ),
                  ),
                  SizedBox(height: context.h(10)),
                  Expanded(
                    child: _invitePlayersBody(context, model, match),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Only the player list scrolls; header (app bar + match title) stays fixed.
  Widget _invitePlayersBody(
    BuildContext context,
    HostDetailScreenViewModel model,
    DiscoveryMatch match,
  ) {
    if (model.usersFetchError != null) {
      return _EmptyState(text: model.usersFetchError!);
    }
    if (model.allUsers.isEmpty && model.isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }
    if (model.allUsers.isEmpty) {
      return _EmptyState(text: AppText.noUsersFound);
    }
    return ListView.builder(
      padding: EdgeInsets.only(bottom: context.h(24)),
      itemCount: model.allUsers.length,
      itemBuilder: (context, index) {
        final user = model.allUsers[index];
        final userId = user.id?.trim() ?? '';
        final sport =
            user.sports?.isNotEmpty == true ? user.sports!.first : null;

        return Padding(
          padding: EdgeInsets.only(bottom: context.h(10)),
          child: PersonInvitedCard(
            avatarUrl: user.avatarUrl,
            playerName: user.fullName,
            matchName: sport?.sport ?? widget.match.sport,
            matchLevel: sport?.skillLevel ?? widget.match.skillLevel,
            destance: user.location?.trim().isNotEmpty == true
                ? user.location
                : (widget.match.location ??
                      widget.match.facilityAddress ??
                      AppText.location),
            isShow: true,
            isInvited: model.isUserAlreadyInvited(userId),
            isLoading: model.isInvitingUser(userId),
            ontap: () async {
              if (userId.isEmpty) {
                AppSnackBar.show('User id is missing');
                return;
              }

              final message = await model.inviteUserToMatch(
                matchId: widget.match.id,
                userId: userId,
              );

              if (!context.mounted || message == null) return;
              AppSnackBar.show(message);
            },
            cardOnTap: () {
              ListOfAllUserService().recordProfileView(user);
              if (userId.isEmpty) return;
              match.pushPublicProfileForUser(
                context,
                userId: userId,
                displayName: user.fullName ?? '',
              );
            },
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.h(18)),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: context.appText.text14W400.copyWith(
            color: context.appColors.greyDark,
          ),
        ),
      ),
    );
  }
}
