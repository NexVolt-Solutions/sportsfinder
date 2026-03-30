import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class ProfileMySportCardWidget extends StatelessWidget {
  final String sportName;
  final String buttonName;
  final Color? skillLabelColor;

  const ProfileMySportCardWidget({
    super.key,
    required this.sportName,
    required this.buttonName,
    this.skillLabelColor,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      padding: context.padSym(h: 12, v: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NormalText(
            subText: sportName,
            subStyle: context.appText.text12W600.copyWith(
              color: context.appColors.greyDark,
            ),
          ),
          CardWidget(
            padding: context.padSym(h: 6, v: 4),
            child: NormalText(
              titleText: buttonName,
              titleColor: skillLabelColor ?? context.appColors.greyDark,
              titleStyle: context.appText.text12W400.copyWith(
                color: skillLabelColor ?? context.appColors.greyDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
