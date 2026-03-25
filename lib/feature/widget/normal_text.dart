import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';

class NormalText extends StatelessWidget {
  final String? titleText;
  final String? subText;

  final TextStyle? titleStyle;
  final TextStyle? subStyle;

  final double? titleFontSize;
  final double? subFontSize;

  final FontWeight? titleFontWeight;
  final FontWeight? subFontWeight;

  final double? sizeBoxheight;

  final Color? titleColor;
  final Color? subColor;

  final TextAlign? titleAlign;
  final TextAlign? subAlign;
  final CrossAxisAlignment? crossAxisAlignment;

  final int? maxLines;
  final TextOverflow? overflow;

  const NormalText({
    super.key,
    this.titleText,
    this.subText,
    this.titleStyle,
    this.subStyle,
    this.titleFontSize,
    this.subFontSize,
    this.titleFontWeight,
    this.subFontWeight,
    this.titleColor,
    this.subColor,
    this.titleAlign,
    this.subAlign,
    this.crossAxisAlignment,
    this.sizeBoxheight,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTitleStyle = context.appText.style(
      fontSize: titleFontSize ?? 16,
      fontWeight: titleFontWeight ?? FontWeight.w500,
      color: titleColor ?? context.appColors.onSurface,
    );

    final defaultSubStyle = context.appText.style(
      fontSize: subFontSize ?? 14,
      fontWeight: subFontWeight ?? FontWeight.w400,
      color: subColor ?? context.appColors.greyDark,
    );

    return Column(
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (titleText != null)
          Text(
            titleText!,
            softWrap: true,
            maxLines: maxLines,
            overflow: overflow ?? TextOverflow.visible,
            style: titleStyle ?? defaultTitleStyle,
            textAlign: titleAlign ?? TextAlign.start,
          ),

        if (sizeBoxheight != null) SizedBox(height: sizeBoxheight),

        if (subText != null)
          Text(
            subText!,
            softWrap: true,
            style: subStyle ?? defaultSubStyle,
            textAlign: subAlign ?? TextAlign.start,
          ),
      ],
    );
  }
}
