import 'package:flutter/material.dart' hide BoxShadow;
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Color? color;
  final Color? colorText;
  final BorderRadius? radius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool isEnabled;
  final CrossAxisAlignment? crossAxisAlignment; // ✅ optional

  const CustomButton({
    super.key,
    this.text,
    this.color,
    this.onTap,
    required this.isEnabled,
    this.colorText,
    this.radius,
    this.padding,
    this.crossAxisAlignment, // ✅
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: context.padSym(v: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: radius ?? BorderRadius.circular(context.radiusR(16)),
        ),
        child: Padding(
          padding: padding ?? context.paddingSymmetricR(horizontal: 0),
          child: NormalText(
            crossAxisAlignment:
                crossAxisAlignment ?? CrossAxisAlignment.center, // ✅ default
            titleText: text ?? '',
            titleSize: context.sp(16),
            titleWeight: FontWeight.w700,
            titleColor: colorText ?? AppColors.whitecolor,
          ),
        ),
      ),
    );
  }
}
