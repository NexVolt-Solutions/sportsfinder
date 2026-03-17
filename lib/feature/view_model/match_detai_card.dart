import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view_model/player_count_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class MatchDetilCard extends StatelessWidget {
  final String headingtitle;
  final String headingSubtitle;
  final String loc;
  final String time;
  final String palyerNo;
  const MatchDetilCard({
    super.key,
    required this.headingtitle,
    required this.headingSubtitle,
    required this.loc,
    required this.time,
    required this.palyerNo,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      padding: context.padSym(h: 16, v: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NormalText(
            crossAxisAlignment: CrossAxisAlignment.start,
            titleText: headingtitle,
            titleColor: AppColors.blackcolor,
            subText: headingSubtitle,
          ),
          SizedBox(height: context.h(8)),
          Row(
            children: [
              SvgPicture.asset(AppAssets.homeLocIcon),
              SizedBox(width: context.w(8)),
              NormalText(
                crossAxisAlignment: CrossAxisAlignment.start,
                titleText: loc,
                titleStyle: context.appText.text12W600,
                titleColor: context.appColors.onSurface,
              ),
            ],
          ),
          SizedBox(height: context.h(4)),
          Row(
            children: [
              SvgPicture.asset(AppAssets.homeTimeIcon),
              SizedBox(width: context.w(8)),
              NormalText(
                crossAxisAlignment: CrossAxisAlignment.start,
                titleText: time,
                titleStyle: context.appText.text12W600,
                titleColor: context.appColors.onSurface,
              ),
            ],
          ),
          SizedBox(height: context.h(8)),
          PlayerCountWidget(playerNo: palyerNo),
        ],
      ),
    );
  }
}
