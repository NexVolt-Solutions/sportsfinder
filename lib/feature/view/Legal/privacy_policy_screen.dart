import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

/// Privacy Policy — typography matches design ref; uses [NormalText] + [AppTextTheme].
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key, this.onEmbeddedClose});

  /// Web profile split shell: leading tap closes the pane instead of popping the route.
  final VoidCallback? onEmbeddedClose;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;

    final welcomeStyle = t.style(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: c.onSurface,
      height: 1.3,
    );
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
                title: AppText.privacyPolicy,
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
                    NormalText(
                      titleText: AppText.welcomeToSportFinding,
                      titleStyle: welcomeStyle,
                    ),
                    SizedBox(height: context.sh(14)),
                    NormalText(
                      titleText: AppText.weValueYourPrivacy,
                      titleStyle: bodyStyle,
                    ),
                    SizedBox(height: context.sh(28)),
                    _sectionNormal(
                      context,
                      AppText.informationWeCollect,
                      sectionStyle,
                    ),
                    SizedBox(height: context.sh(12)),
                    _bulletLabeled(
                      context,
                      AppText.personalInformation,
                      bulletStyle,
                    ),
                    _bulletLabeled(context, AppText.usageData, bulletStyle),
                    _bulletLabeled(context, AppText.locationData, bulletStyle),
                    SizedBox(height: context.sh(24)),
                    _sectionNormal(
                      context,
                      AppText.howWeUseYourInformation,
                      sectionStyle,
                    ),
                    SizedBox(height: context.sh(12)),
                    _bulletPlain(
                      context,
                      AppText.toConnectYouWithPlayersAndMatches,
                      bulletStyle,
                    ),
                    _bulletPlain(
                      context,
                      AppText
                          .toSendNotificationsAboutUpcomingGamesInvitationsAndUpdates,
                      bulletStyle,
                    ),
                    _bulletPlain(
                      context,
                      AppText
                          .toImproveTheAppExperienceAndProvidePersonalizedRecommendations,
                      bulletStyle,
                    ),
                    _bulletPlain(
                      context,
                      AppText.toMaintainASecureEnvironment,
                      bulletStyle,
                    ),
                    SizedBox(height: context.sh(24)),
                    _sectionNormal(
                      context,
                      AppText.privateFollowingFeature,
                      sectionStyle,
                    ),
                    SizedBox(height: context.sh(12)),
                    _bulletPlain(
                      context,
                      AppText.usersCanFollowOthersPrivately,
                      bulletStyle,
                    ),
                    _bulletPlain(
                      context,
                      AppText.onlyYouCanSeeYourFollowingAndFollowersLists,
                      bulletStyle,
                    ),
                    _bulletPlain(
                      context,
                      AppText
                          .noOtherUsersCanAccessSomeoneElsesFollowersOrFollowing,
                      bulletStyle,
                    ),
                    SizedBox(height: context.sh(24)),
                    _sectionNormal(
                      context,
                      AppText.sharingYourInformation,
                      sectionStyle,
                    ),
                    SizedBox(height: context.sh(12)),
                    _bulletPlain(
                      context,
                      AppText.weDoNotSellOrShareYourPersonalInformation,
                      bulletStyle,
                    ),
                    _bulletPlain(
                      context,
                      AppText.yourProfileInfoIsVisibleToOtherPlayers,
                      bulletStyle,
                    ),
                    _bulletPlain(
                      context,
                      AppText.locationIsOnlySharedToShowNearbyMatches,
                      bulletStyle,
                    ),
                    SizedBox(height: context.sh(24)),
                    _sectionNormal(context, AppText.security, sectionStyle),
                    SizedBox(height: context.sh(12)),
                    _bulletPlain(
                      context,
                      AppText.weUseEncryptionAndSecureServersToProtectYourData,
                      bulletStyle,
                    ),
                    _bulletPlain(
                      context,
                      AppText.keepYourPasswordSafe,
                      bulletStyle,
                    ),
                    SizedBox(height: context.sh(24)),
                    _sectionNormal(context, AppText.yourChoices, sectionStyle),
                    SizedBox(height: context.sh(12)),
                    _bulletPlain(
                      context,
                      AppText.youCanDisableNotifications,
                      bulletStyle,
                    ),
                    _bulletPlain(
                      context,
                      AppText.youCanDeleteYourAccountAtAnyTime,
                      bulletStyle,
                    ),
                    SizedBox(height: context.sh(24)),
                    _sectionNormal(
                      context,
                      AppText.childrensPrivacy,
                      sectionStyle,
                    ),
                    SizedBox(height: context.sh(12)),
                    NormalText(
                      titleText: AppText.ourAppIsNotIntendedForChildrenUnder13,
                      titleStyle: bodyStyle,
                    ),
                    SizedBox(height: context.sh(24)),
                    _sectionNormal(
                      context,
                      AppText.changesToPrivacyPolicy,
                      sectionStyle,
                    ),
                    SizedBox(height: context.sh(12)),
                    NormalText(
                      titleText: AppText.weMayUpdateThisPolicyOccasionally,
                      titleStyle: bodyStyle,
                      maxLines: 6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sectionNormal(
    BuildContext context,
    String text,
    TextStyle sectionStyle,
  ) {
    return NormalText(titleText: text, titleStyle: sectionStyle);
  }

  /// Bullet with bold label before first ':' (matches mock: **Personal Information:** …).
  static Widget _bulletLabeled(
    BuildContext context,
    String text,
    TextStyle bulletStyle,
  ) {
    final t = context.appText;
    final colon = text.indexOf(':');

    if (colon <= 0 || colon >= text.length - 1) {
      return Padding(
        padding: EdgeInsets.only(bottom: context.sh(8)),
        child: _bulletRow(
          context,
          NormalText(titleText: text, titleStyle: bulletStyle),
        ),
      );
    }

    final label = text.substring(0, colon + 1);
    final rest = text.substring(colon + 1).trimLeft();
    final labelStyle = t.text14Bold.copyWith(
      color: bulletStyle.color,
      height: bulletStyle.height,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: context.sh(8)),
      child: _bulletRow(
        context,
        Text.rich(
          TextSpan(
            style: bulletStyle,
            children: [
              TextSpan(text: label, style: labelStyle),
              if (rest.isNotEmpty) TextSpan(text: ' $rest'),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _bulletPlain(
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
