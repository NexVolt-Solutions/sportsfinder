import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class WebDashboardPanel extends StatelessWidget {
  const WebDashboardPanel({
    super.key,
    required this.child,
    this.padding,
    this.height,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? context.padSym(h: 18, v: 18),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.whitecolor,
        borderRadius: BorderRadius.circular(context.radius(18)),
        border: Border.all(color: AppColors.transparent),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0B0E4A84),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class WebDashboardTitle extends StatelessWidget {
  const WebDashboardTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.appText.text18Bold.copyWith(
                  color: context.appColors.onSurface,
                ),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                SizedBox(height: context.h(4)),
                Text(
                  subtitle!,
                  style: context.appText.text12W400.copyWith(
                    color: context.appColors.greylight,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class WebQuickActionCard extends StatelessWidget {
  const WebQuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final Widget icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.radius(16)),
           
        ),
        child: Container(
          padding: context.padSym(h: 16, v: 16),
           decoration: BoxDecoration(
            color: context.appColors.blue10,
            borderRadius: BorderRadius.circular(context.radius(16)),
           ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(height: context.h(10)),
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.appText.text14W500.copyWith(
                  color: context.appColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
