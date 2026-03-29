import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final String? actionText;
  final String? icon;
  final VoidCallback? onTap;

  const SectionHeaderWidget({
    super.key,
    required this.title,
    this.actionText,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        NormalText(
          crossAxisAlignment: CrossAxisAlignment.center,
          titleText: title,
          maxLines: 2,
        ),

        if (actionText != null)
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                NormalText(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  titleText: actionText!,
                  maxLines: 2,
                  titleColor: context.appColors.primary,
                ),

                SizedBox(width: context.w(10)),
                SvgPicture.asset(icon ?? AppAssets.nextIcon),
              ],
            ),
          ),
      ],
    );
  }
}
