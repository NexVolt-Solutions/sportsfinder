import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class CardWidget extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? borderRadius;

  const CardWidget({
    super.key,
    this.child,
    this.padding,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius ?? context.radiusR(12)),
      child: Container(
        padding: padding ?? context.padSym(h: 12, v: 12),
        margin: context.padSym(v: 12),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.blue10,
          borderRadius: BorderRadius.circular(
            borderRadius ?? context.radiusR(12),
          ),
          border: Border.all(color: borderColor ?? AppColors.bluecolor),
        ),
        child: child ?? const SizedBox(),
      ),
    );
  }
}
