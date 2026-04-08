import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class MatchCardButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback ontap;

  const MatchCardButton({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Card(
        child: Container(
          padding: context.padSym(h: 10, v: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(context.radiusR(12)),
          ),
          child: NormalText(
            titleText: text,
            titleStyle: context.appText.text12W600.copyWith(
              height: 1.5,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
