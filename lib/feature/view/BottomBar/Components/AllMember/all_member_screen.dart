import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/chat_route_args.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/all_member_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/person_invited_card.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';

class AllMemberScreen extends StatefulWidget {
  const AllMemberScreen({super.key});

  @override
  State<AllMemberScreen> createState() => _AllMemberScreenState();
}

class _AllMemberScreenState extends State<AllMemberScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AllMemberScreenViewModel>(
      builder: (context, model, child) => Scaffold(
        body: MainFrame(
          child: Padding(
            padding: context.padSym(h: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 AppBarWidget(
                  onTapFirst: () => Navigator.pop(context),
                  title: AppText.invitePlayers,
                ),
                NormalText(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  titleText: AppText.allMembers,
                ),
                SizedBox(height: context.h(8)),
                SearchBarWidget(
                  isShow: false,
                  onChanged: model.searchUsers,
                ),
                SizedBox(height: context.h(16)),
                Expanded(
                  child: model.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : model.errorMessage != null
                      ? Center(
                          child: Text(
                            model.errorMessage!,
                            textAlign: TextAlign.center,
                            style: context.appText.text14W400.copyWith(
                              color: context.appColors.greyDark,
                            ),
                          ),
                        )
                      : model.users.isEmpty
                      ? Center(
                          child: Text(
                            AppText.noUsersFound,
                            style: context.appText.text14W400.copyWith(
                              color: context.appColors.greyDark,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: model.users.length,
                          itemBuilder: (context, index) {
                            final user = model.users[index];
                            final firstSport = user.sports?.isNotEmpty == true
                                ? user.sports!.first
                                : null;

                            return Padding(
                              padding: context.paddingOnly(bottom: context.h(10)),
                              child: PersonInvitedCard(
                                avatarUrl: user.avatarUrl,
                                cardOnTap: () => Navigator.pop(
                                  context,
                                  ChatRouteArgs(
                                    contactName: (user.fullName ?? '').trim(),
                                    targetUserId: (user.id ?? '').trim(),
                                    contactAvatarUrl: user.avatarUrl,
                                  ),
                                ),
                                playerName: user.fullName,
                                matchLevel: firstSport?.skillLevel ?? '',
                                matchName: firstSport?.sport ?? '',
                                destance: user.location ?? '',
                                ontap: () {},
                              ),
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
