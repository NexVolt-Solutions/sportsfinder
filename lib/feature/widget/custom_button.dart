import 'package:flutter/material.dart' hide BoxShadow;
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Color? color;
  final Color? colorText;
  final BorderRadius? radius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment? crossAxisAlignment;
  final Widget? leading;
  final bool outlined;
  final Color? borderColor;
  final TextStyle? titleStyle;
  final bool isLoading;

  const CustomButton({
    super.key,
    this.text,
    this.color,
    this.onTap,
    this.colorText,
    this.radius,
    this.padding,
    this.crossAxisAlignment,
    this.leading,
    this.outlined = false,
    this.borderColor,
    this.titleStyle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;

    final backgroundColor = outlined
        ? (color ?? c.transparent)
        : (color ?? c.primary);
    final labelColor = colorText ?? (outlined ? c.greyDark : c.onPrimary);

    final effectiveTitleStyle =
        titleStyle ??
        (outlined
            ? t.text16W500.copyWith(color: labelColor)
            : t.text16Bold.copyWith(color: labelColor));

    final label = NormalText(
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      titleText: text ?? '',
      titleStyle: effectiveTitleStyle,
    );

    final content = isLoading
        ? SizedBox(
            height: context.h(20),
            width: context.h(20),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(labelColor),
            ),
          )
        : (leading != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    leading!,
                    SizedBox(width: context.w(8)),
                    label,
                  ],
                )
              : label);

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: padding ?? context.padAll(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          // Keep default radius fixed across platforms (mobile + web).
          borderRadius: radius ?? BorderRadius.circular(context.radius(12)),
          border: outlined
              ? Border.all(color: borderColor ?? AppColors.greylight, width: 1)
              : null,
        ),
        child: Padding(
          padding: padding ?? context.paddingSymmetricR(horizontal: 0),
          child: Center(child: content),
        ),
      ),
    );
  }
}
