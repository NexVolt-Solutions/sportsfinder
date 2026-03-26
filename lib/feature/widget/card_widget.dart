// import 'package:flutter/material.dart';
// import 'package:sport_finding/core/Constants/app_theme.dart';
// import 'package:sport_finding/core/Constants/size_extension.dart';

// class CardWidget extends StatelessWidget {
//   final Widget? child;
//   final EdgeInsetsGeometry? padding;
//   final VoidCallback? onTap;
//   final Color? borderColor;
//   final Color? backgroundColor;
//   final double? borderRadius;

//   const CardWidget({
//     super.key,
//     this.child,
//     this.padding,
//     this.onTap,
//     this.borderColor,
//     this.backgroundColor,
//     this.borderRadius,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final c = context.appColors;
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: padding ?? context.padSym(h: 12, v: 12),
//         margin: context.padSym(v: 12),
//         decoration: BoxDecoration(
//           color: backgroundColor ?? c.blue10,
//           borderRadius: BorderRadius.circular(
//             borderRadius ?? context.radiusR(12),
//           ),
//           border: Border.all(color: borderColor ?? c.transparent),
//         ),
//         child: child ?? const SizedBox(),
//       ),
//     );
//   }
// }
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? context.padSym(h: 12, v: 12),
        margin: context.padSym(v: 12),
        decoration: BoxDecoration(
          color: backgroundColor ?? c.blue10,
          borderRadius: BorderRadius.circular(
            borderRadius ?? context.radiusR(12),
          ),
          border: Border.all(
            color: isActive
                ? (activeBorderColor ?? c.primary)
                : (borderColor ?? Colors.transparent),
            width: 1.5,
          ),
        ),
        child: child ?? const SizedBox(),
      ),
    );
  }
}
