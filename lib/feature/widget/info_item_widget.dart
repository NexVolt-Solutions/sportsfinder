import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/app_svg_icon.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class InfoItem extends StatelessWidget {
  final String icon;
  final String title;
  final String value;

  const InfoItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CardWidget(
          padding: context.padAll(4),
          child: AppSvgIcon(icon: icon, color: context.appColors.primary),
        ),
        SizedBox(width: context.w(8)),
        NormalText(titleText: title, subText: value),
      ],
    );
  }
}
