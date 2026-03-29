import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

/// In-app notifications list (demo copy from [AppText]).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const List<({String title, String subtitle})> _items = [
    (
      title: AppText.rimshaInvitedYouToJoinABasketballMatch,
      subtitle: AppText.twoMinutesAgo,
    ),
    (
      title: AppText.hinaJoinedYourMatch,
      subtitle: AppText.fifteenMinutesAgo,
    ),
    (
      title: AppText.taifLeftYourMatch,
      subtitle: AppText.oneHourAgo,
    ),
    (
      title: AppText.yourFinalTournamentIsNowFull,
      subtitle: AppText.yesterday,
    ),
    (
      title: AppText.alexStartedTheGame,
      subtitle: AppText.yesterday,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainFrame(
        child: Padding(
          padding: context.padSym(h: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBarWidget(
                onTapFirst: () => Navigator.pop(context),
                title: AppText.notifications,
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: _items.length,
                  padding: EdgeInsets.only(top: context.h(8)),
                  separatorBuilder: (context, _) =>
                      Divider(height: 1, color: context.appColors.blue10),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: context.h(12)),
                      child: NormalText(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        titleText: item.title,
                        titleStyle: context.appText.text14W500,
                        titleColor: context.appColors.onSurface,
                        sizeBoxheight: context.h(6),
                        subText: item.subtitle,
                        subColor: context.appColors.greylight,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
