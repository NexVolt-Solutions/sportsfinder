import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class SocialButtonWidget extends StatelessWidget {
  final String imagePath;
  final String text;
  final VoidCallback? onTap;

  final Color? borderColor;
  final Color? textColor;
  final Color? backgroundColor;

  final bool showBorder;

  const SocialButtonWidget({
    super.key,
    required this.imagePath,
    required this.text,
    this.onTap,
    this.borderColor,
    this.textColor,
    this.backgroundColor,
    this.showBorder = true, // 👈 default border ON
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: context.padSym(v: 13),
        decoration: BoxDecoration(
          color: backgroundColor ?? c.transparent, // 👈 background added
          borderRadius: BorderRadius.circular(context.radiusR(12)),

          // 👇 optional border
          border: showBorder
              ? Border.all(color: borderColor ?? c.primary)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              imagePath,
              fit: BoxFit.contain,
              height: context.h(20),
            ),

            SizedBox(width: context.w(12)),

            Text(
              text,
              style: context.appText.text14W400.copyWith(
                color: textColor ?? c.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
