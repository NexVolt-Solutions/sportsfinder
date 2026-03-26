import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class CustomCardWidget extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? borderRadius;

  const CustomCardWidget({
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
    final c = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? context.padSym(h: 12, v: 12), // ✅ your padding
        margin: context.padSym(v: 12), // ✅ space between cards
        decoration: BoxDecoration(
          color: backgroundColor ?? c.blue10, // ✅ your color
          borderRadius: BorderRadius.circular(
            borderRadius ?? context.radiusR(12),
          ),
          border: Border.all(
            color: borderColor ?? Colors.transparent,
            width: 1.5,
          ),
        ),
        child: child ?? const SizedBox(),
      ),
    );
  }
}
