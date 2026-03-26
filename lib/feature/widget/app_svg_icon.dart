import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class AppSvgIcon extends StatelessWidget {
  final String icon;
  final double size;
  final Color? color;

  const AppSvgIcon({
    super.key,
    required this.icon,
    this.size = 24, // ✅ default 24x24
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.h(size),
      width: context.w(size),
      child: SvgPicture.asset(
        icon,
        fit: BoxFit.scaleDown,
        colorFilter: ColorFilter.mode(color ?? Colors.blue, BlendMode.srcIn),
      ),
    );
  }
}
