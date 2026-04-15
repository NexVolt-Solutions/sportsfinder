import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/match_card_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class MySportCard extends StatelessWidget {
  final String? matchName;
  final String? matchLevel;
  final VoidCallback? cardOnTap;
  final VoidCallback buttonOnTap;
  const MySportCard({
    super.key,
    this.matchName,
    this.matchLevel,
    this.cardOnTap,
    required this.buttonOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      onTap: cardOnTap,
      padding: context.padSym(h: 16, v: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NormalText(
            titleText: matchName ?? AppText.football,
            titleColor: context.appColors.onSurface,
          ),
          MatchCardButton(
            ontap: buttonOnTap,
            text: matchLevel ?? AppText.advanced,
            color: context.appColors.surface,
            textColor: context.appColors.primary,
          ),
        ],
      ),
    );
  }
}
