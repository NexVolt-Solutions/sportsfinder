import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/create_match_request_model.dart';
import 'package:sport_finding/Data/model/public_profile_args.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Network/list_of_all_user_service.dart';
import 'package:sport_finding/core/Routes/discovery_match_navigation.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/feature/view/Home/viewModel/host_detail_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/person_invited_card.dart';
import 'package:sport_finding/feature/widget/user_match_card_widget.dart';

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
            child: ListView(
              padding: context.padSym(h: 20),
              children: [
                SizedBox(height: context.h(20)),
                AppBarWidget(
                  onTapFirst: () => Navigator.pop(context),
                  title: AppText.sportFinding,
                ),
                SizedBox(height: context.h(20)),
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
                SizedBox(height: context.h(24)),
                _SectionTitle(
                  title: AppText.participatedPlayers,
                  trailing: model.isRefreshingRoster
                      ? SizedBox(
                          height: context.h(18),
                          width: context.h(18),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : null,
                ),
                SizedBox(height: context.h(10)),
                if (model.rosterCount == 0)
                  _EmptyState(text: AppText.noPlayersOnRoster)
                else
                  ...List.generate(model.rosterCount, (index) {
                    final userId = model.rosterUserIdAt(index).trim();
                    return Padding(
                      padding: EdgeInsets.only(bottom: context.h(10)),
                      child: UserMatchCard(
                        avatarUrl: model.rosterAvatarUrlAt(index),
                        title: model.rosterNameAt(index),
                        subTitle: model.rosterSkillAt(index),
                        onCardTap: userId.isEmpty
                            ? null
                            : () {
                                Navigator.pushNamed(
                                  context,
                                  RoutesName.publicProfileScreen,
                                  arguments: PublicProfileArgs(
                                    userId: userId,
                                    displayName: model.rosterNameAt(index),
                                    initialMatchId: widget.match.id,
                                    canRateForMatch: false,
                                  ),
                                );
                              },
                      ),
                    );
                  }),
                SizedBox(height: context.h(20)),
                _SectionTitle(
                  title: AppText.invitePlayers,
                  trailing: model.isLoadingUsers
                      ? SizedBox(
                          height: context.h(18),
                          width: context.h(18),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : GestureDetector(
                          onTap: () => model.refreshUsers(),
                          child: Icon(
                            Icons.refresh,
                            color: context.appColors.primary,
                            size: 22,
                          ),
                        ),
                ),
                SizedBox(height: context.h(10)),
                if (model.usersFetchError != null)
                  _EmptyState(text: model.usersFetchError!)
                else if (model.allUsers.isEmpty && model.isLoadingUsers)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (model.allUsers.isEmpty)
                  _EmptyState(text: AppText.noUsersFound)
                else
                  ...List.generate(model.allUsers.length, (index) {
                    final user = model.allUsers[index];
                    final userId = user.id?.trim() ?? '';
                    final sport = user.sports?.isNotEmpty == true
                        ? user.sports!.first
                        : null;

                    return Padding(
                      padding: EdgeInsets.only(bottom: context.h(10)),
                      child: PersonInvitedCard(
                        avatarUrl: user.avatarUrl,
                        playerName: user.fullName,
                        matchName: sport?.sport ?? widget.match.sport,
                        matchLevel:
                            sport?.skillLevel ?? widget.match.skillLevel,
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
                  }),
                SizedBox(height: context.h(24)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: context.appText.text16W500.copyWith(
              color: context.appColors.onSurface,
            ),
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: context.w(8)),
          trailing!,
        ],
      ],
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
