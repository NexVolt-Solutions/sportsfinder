import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CustomButton({
    super.key,
    this.text,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? context.padSym(v: 11),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.whiteColor,
        borderRadius: BorderRadius.circular(borderRadius ?? context.radius(6)),
      ),
      child: Center(
        child: Text(
          text ?? 'Get Started',
          style: TextStyle(
            color: textColor ?? AppColors.purpleColor,
            fontSize: fontSize ?? context.mediumText,
            fontWeight: fontWeight ?? FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
