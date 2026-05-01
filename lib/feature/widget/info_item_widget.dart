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
  final int maxLines;
  final TextOverflow overflow;

  const InfoItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.maxLines = 2,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width * 0.9;
        final textMaxWidth = (availableWidth - context.w(56)).clamp(0.0, double.infinity);
        final text = NormalText(
          maxLines: maxLines,
          overflow: overflow,
          titleText: title,
          subText: value,
        );
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CardWidget(
              padding: context.padAll(4),
              child: AppSvgIcon(icon: icon, color: context.appColors.primary),
            ),
            SizedBox(width: context.w(8)),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: textMaxWidth),
              child: text,
            ),
          ],
        );
      },
    );
  }
}
