import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class CustomSettingCard extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final String? trailingType; // "arrow" or "switch"
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback? onTap;

  const CustomSettingCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingType,
    this.switchValue,
    this.onSwitchChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget? trailingWidget;

    if (trailingType == 'arrow') {
      trailingWidget = const Icon(Icons.arrow_forward_ios, size: 16);
    } else if (trailingType == 'switch') {
      trailingWidget = Switch(
        value: switchValue ?? false,
        onChanged: onSwitchChanged,
        activeThumbColor: context.appColors.primary,
      );
    }

    return CardWidget(
      onTap: trailingType != 'switch'
          ? onTap
          : null, // Only tapable if not switch
      padding: context.padSym(h: 16, v: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// 🔹 LEFT SIDE
          Expanded(
            child: Row(
              children: [
                SvgPicture.asset(icon),
                SizedBox(width: context.w(20)),
                Expanded(
                  child: NormalText(
                    titleText: title,
                    subText: subtitle,
                    subFontSize: context.text(12),
                    subFontWeight: FontWeight.w400,
                    subColor: context.appColors.greylight,
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 RIGHT SIDE (Optional)
          ?trailingWidget,
        ],
      ),
    );
  }
}
