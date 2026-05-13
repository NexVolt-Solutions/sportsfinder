import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

/// Terms of Service — same layout/typography pattern as [PrivacyPolicyScreen].
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key, this.onEmbeddedClose});

  /// Web profile split shell: leading tap closes the pane instead of popping the route.
  final VoidCallback? onEmbeddedClose;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;

    final bodyStyle = t.text14W400.copyWith(
      color: c.onSurface.withValues(alpha: 0.87),
      height: 1.48,
    );
    final sectionStyle = t.text16Bold.copyWith(color: c.onSurface, height: 1.3);
    final bulletStyle = t.text14W400.copyWith(color: c.greyDark, height: 1.48);

    return Scaffold(
      backgroundColor: onEmbeddedClose != null
          ? Colors.transparent
          : Theme.of(context).scaffoldBackgroundColor,
      body: MainFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: context.padSym(h: 20),
              child: AppBarWidget(
                title: AppText.termsOfServiceTitle,
                onLeadingTap:
                    onEmbeddedClose ?? () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: context.padSym(h: 20).copyWith(bottom: context.h(32)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section(context, AppText.acceptanceOfTerms, sectionStyle),
                    SizedBox(height: context.sh(12)),
                    NormalText(
                      titleText: AppText.byUsingSportFindingYouAgreeToFollowTheseTerms,
                      titleStyle: bodyStyle,
                    ),
                    SizedBox(height: context.sh(24)),
                    _section(context, AppText.account, sectionStyle),
                    SizedBox(height: context.sh(12)),
                    _bullet(context, AppText.youMustProvideAccurateInformationDuringRegistration, bulletStyle),
                    _bullet(context, AppText.keepYourAccountSecure, bulletStyle),
                    _bullet(context, AppText.youAreResponsibleForActivityUnderYourAccount, bulletStyle),
                    SizedBox(height: context.sh(24)),
                    _section(context, AppText.creatingAndJoiningMatches, sectionStyle),
                    SizedBox(height: context.sh(12)),
                    _bullet(context, AppText.hostsControlWhenAGameStarts, bulletStyle),
                    _bullet(context, AppText.hostsCanRemovePlayersIfNeededBeforeStartingAMatch, bulletStyle),
                    _bullet(context, AppText.onlyTheHostCanOfficiallyStartTheGame, bulletStyle),
                    SizedBox(height: context.sh(24)),
                    _section(context, AppText.userConduct, sectionStyle),
                    SizedBox(height: context.sh(12)),
                    _bullet(context, AppText.respectOtherPlayers, bulletStyle),
                    _bullet(context, AppText.noCheatingOrFalsifyingYourSkillLevel, bulletStyle),
                    _bullet(context, AppText.doNotShareOtherUsersPrivateInformation, bulletStyle),
                    SizedBox(height: context.sh(24)),
                    _section(context, AppText.privateFollowing, sectionStyle),
                    SizedBox(height: context.sh(12)),
                    _bullet(context, AppText.followingOtherUsersIsPrivate, bulletStyle),
                    _bullet(context, AppText.doNotAttemptToAccessSomeoneElsesFollowLists, bulletStyle),
                    SizedBox(height: context.sh(24)),
                    _section(context, AppText.content, sectionStyle),
                    SizedBox(height: context.sh(12)),
                    _bullet(context, AppText.anyContentYouPostMustComply, bulletStyle),
                    _bullet(context, AppText.sportFindingMayRemoveContentViolatingTheRules, bulletStyle),
                    SizedBox(height: context.sh(24)),
                    _section(context, AppText.liability, sectionStyle),
                    SizedBox(height: context.sh(12)),
                    _bullet(context, AppText.sportFindingIsNotResponsibleForInjuriesDisputesOrAccidents, bulletStyle),
                    _bullet(context, AppText.usersJoinMatchesAtTheirOwnRisk, bulletStyle),
                    SizedBox(height: context.sh(24)),
                    _section(context, AppText.termination, sectionStyle),
                    SizedBox(height: context.sh(12)),
                    _bullet(context, AppText.weMaySuspendOrTerminateYourAccount, bulletStyle),
                    _bullet(context, AppText.youCanDeleteYourAccountAnytime, bulletStyle),
                    SizedBox(height: context.sh(24)),
                    _section(context, AppText.changes, sectionStyle),
                    SizedBox(height: context.sh(12)),
                    _bullet(context, AppText.weMayUpdateTheseTerms, bulletStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _section(
    BuildContext context,
    String text,
    TextStyle sectionStyle,
  ) {
    return NormalText(titleText: text, titleStyle: sectionStyle);
  }

  static Widget _bullet(
    BuildContext context,
    String text,
    TextStyle bulletStyle,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.sh(8)),
      child: _bulletRow(
        context,
        NormalText(titleText: text, titleStyle: bulletStyle, maxLines: 6),
      ),
    );
  }

  static Widget _bulletRow(BuildContext context, Widget line) {
    final c = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: context.sh(6)),
          child: Container(
            width: context.w(5),
            height: context.w(5),
            decoration: BoxDecoration(
              color: c.onSurface,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: context.w(12)),
        Expanded(child: line),
      ],
    );
  }
}
