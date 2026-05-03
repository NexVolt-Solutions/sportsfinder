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
    final c = context.appColors;
    final effectiveRadius = borderRadius ?? context.radius(kIsWeb ? 18 : 12);
    final effectiveBackground =
        backgroundColor ?? (kIsWeb ? AppColors.blue10 : null);
    final effectiveBorderColor = isActive
        ? (activeBorderColor ?? c.primary)
        : (borderColor ??
              (kIsWeb ? const Color(0xFFD7E7F7) : Colors.transparent));

    return GestureDetector(
      onTap: onTap,
      behavior: onTap != null
          ? HitTestBehavior.opaque
          : HitTestBehavior.deferToChild,
      child: Card(
        margin: context.padSym(v: kIsWeb ? 0 : 8),
        elevation: kIsWeb ? 0 : elevation,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveRadius),
        ),
        color: Colors.transparent,
        child: Container(
          padding:
              padding ??
              context.padSym(h: kIsWeb ? 18 : 12, v: kIsWeb ? 18 : 12),
          decoration: BoxDecoration(
            color: effectiveBackground,
            gradient: kIsWeb
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.blue10, AppColors.blue20],
                  ),
            borderRadius: BorderRadius.circular(effectiveRadius),
            border: Border.all(color: effectiveBorderColor, width: 1.5),
            boxShadow: kIsWeb
                ? const [
                    BoxShadow(
                      color: Color(0x0B0E4A84),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: child ?? const SizedBox(),
        ),
      ),
    );
  }
}
