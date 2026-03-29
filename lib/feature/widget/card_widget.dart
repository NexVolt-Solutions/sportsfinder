import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class CardWidget extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool isActive; // controlled by parent
  final Color? activeBorderColor;

  const CardWidget({
    super.key,
    this.child,
    this.padding,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius,
    this.isActive = false,
    this.activeBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: padding ?? context.padSym(h: 12, v: 24),
      margin: context.padSym(v: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.appColors.blue10,
        borderRadius: BorderRadius.circular(context.radiusR(12)),

        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child ?? const SizedBox(),
    );
  }
}
