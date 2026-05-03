import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class WebDashboardPanel extends StatelessWidget {
  const WebDashboardPanel({
    super.key,
    required this.child,
    this.padding,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? context.padSym(h: 18, v: 18),
      decoration: BoxDecoration(
        color: context.appColors.blue10,
        borderRadius: BorderRadius.circular(context.radiusR(12)),
        border: Border.all(color: context.appColors.transparent),
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
        color: const Color(0xFFF2F8FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.radiusR(12)),
          side: const BorderSide(color: Color(0xFFD7E7F7)),
        ),
        child: Container(
          padding: context.padSym(h: 164, v: 28),
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
