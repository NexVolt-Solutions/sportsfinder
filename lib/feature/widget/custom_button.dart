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
  final CrossAxisAlignment? crossAxisAlignment; // ✅ optional

  const CustomButton({
    super.key,
    this.text,
    this.color,
    this.onTap,
    this.colorText,
    this.radius,
    this.padding,
    this.crossAxisAlignment, // ✅
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            overlayColor: AppColors.transparent,
            foregroundColor: context.appColors.onSurface,
            surfaceTintColor: AppColors.transparent,
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(12),
            ),
            padding:
                padding ??
                context.paddingSymmetricR(horizontal: 20, vertical: 12),
          ),
          onPressed: onTap,

          child: NormalText(
            titleText: text ?? '',
            titleColor: context.appColors.surface,
          ),
        ),
      ),

      //  Container(
      //   margin: context.padSym(v: 20),
      //   width: double.infinity,
      //   padding: context.padSym(v: 14),
      //   decoration: BoxDecoration(
      //     color: color,
      //     borderRadius: radius ?? BorderRadius.circular(context.radiusR(12)),
      //   ),
      //   child: Padding(
      //     padding: padding ?? context.paddingSymmetricR(horizontal: 0),
      //     child: NormalText(
      //       crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      //       titleText: text ?? '',
      //       titleColor: context.appColors.surface,
      //     ),
      //   ),
      // ),
    );
  }
}
