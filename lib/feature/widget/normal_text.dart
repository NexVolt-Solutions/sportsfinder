import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';

class NormalText extends StatelessWidget {
  final String? titleText;
  final String? subText;

  /// When null, uses [AppTextTheme]: title → text16W500, sub → text14W400.
  final TextStyle? titleStyle;
  final TextStyle? subStyle;

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
    return Column(
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (titleText != null)
          Flexible(
            child: Text(
              titleText!,
              softWrap: true,
              maxLines: maxLines,
              overflow: overflow ?? TextOverflow.visible,
              style: (titleStyle ?? context.appText.text16W500).copyWith(
                color: titleColor ?? context.appColors.onSurface,
              ),
              textAlign: titleAlign ?? TextAlign.start,
            ),
          ),

        if (sizeBoxheight != null) SizedBox(height: sizeBoxheight),

        if (subText != null)
          Text(
            subText!,
            softWrap: true,
            maxLines: null,
            overflow: TextOverflow.visible,
            style: (subStyle ?? context.appText.text14W400).copyWith(
              color: subColor ?? context.appColors.greyDark,
            ),
            textAlign: subAlign ?? TextAlign.start,
          ),
      ],
    );
  }
}
