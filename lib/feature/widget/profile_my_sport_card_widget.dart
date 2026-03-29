import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class ProfileMySportCardWidget extends StatelessWidget {
  final String sportName;
  final String buttonName;
  const ProfileMySportCardWidget({
    super.key,
    required this.sportName,
    required this.buttonName,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      padding: context.padSym(h: 16, v: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NormalText(subText: sportName),
          CardWidget(
            padding: context.padSym(h: 24, v: 8),

            child: NormalText(
              titleText: buttonName,

              titleColor: context.appColors.greyDark,
              titleFontSize: context.text(13),
              titleFontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
