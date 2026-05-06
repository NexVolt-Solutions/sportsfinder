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
  final bool switchEnabled;
  final bool switchLoading;

  const CustomSettingCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingType,
    this.switchValue,
    this.onSwitchChanged,
    this.onTap,
    this.switchEnabled = true,
    this.switchLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget? trailingWidget;

    if (trailingType == 'arrow') {
      trailingWidget = const Icon(Icons.arrow_forward_ios, size: 16);
    } else if (trailingType == 'switch') {
      final canToggle =
          switchEnabled && !switchLoading && onSwitchChanged != null;
      trailingWidget = Switch(
        value: switchValue ?? false,
        onChanged: canToggle ? onSwitchChanged : null,
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
                SvgPicture.asset(
                  icon,
                  width: context.w(24),
                  height: context.h(24),
                ),
                SizedBox(width: context.w(8)),
                Expanded(
                  child: NormalText(
                    titleText: title,
                    titleStyle: context.appText.text14W600.copyWith(
                      color: context.appColors.greyDark,
                    ),
                    subText: subtitle,
                    maxLines: 2,
                    subStyle: context.appText.text12W400.copyWith(
                      color: context.appColors.greyDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          trailingWidget ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
