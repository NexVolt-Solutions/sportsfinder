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
//             borderRadius ?? context.radius(12),
//           ),
//           border: Border.all(color: borderColor ?? c.transparent),
//         ),
//         child: child ?? const SizedBox(),
//       ),
//     );
//   }
// }
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
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
  final double elevation;

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
    this.elevation = 1,
  });

  @override
  Widget build(BuildContext context) {
 
    return GestureDetector(
      onTap: onTap,
      behavior: onTap != null
          ? HitTestBehavior.opaque
          : HitTestBehavior.deferToChild,
      child: Card(
        child: Container(
          padding:
              padding ?? context.padSym(h: 16, v: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [context.appColors.blue10, context.appColors.blue20],
            ),
            borderRadius: BorderRadius.circular(context.radius( 12)),
           ),
          child: child ?? const SizedBox(),
        ),
      ),
    );
  }
}
