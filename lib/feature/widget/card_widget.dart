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
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class CardWidget extends StatefulWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? borderRadius;
  final Color? activeBorderColor; // new property

  const CardWidget({
    super.key,
    this.child,
    this.padding,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius,
    this.activeBorderColor,
  });

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  bool isActive = false;

  void handleTap() {
    setState(() {
      isActive = !isActive;
    });

    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: handleTap,
      child: Card(
        child: Container(
          padding: widget.padding ?? context.padSym(h: 12, v: 12),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? c.blue10,
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? context.radiusR(12),
            ),
            border: Border.all(
              color: isActive
                  ? (widget.activeBorderColor ?? AppColors.bluecolor)
                  : (widget.borderColor ?? c.transparent),
              width: 1,
            ),
          ),
          child: widget.child ?? const SizedBox(),
        ),
      ),
    );
  }
}
