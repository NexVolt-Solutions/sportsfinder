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
    final hasAction = actionText != null;
    return Row(
      children: [
        Expanded(
          child: NormalText(
            crossAxisAlignment: CrossAxisAlignment.center,
            titleText: title,
            maxLines: hasAction ? 1 : 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        if (actionText != null) ...[
          SizedBox(width: context.w(12)),
          Flexible(
            child: GestureDetector(
              onTap: onTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: NormalText(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      titleText: actionText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      titleColor: context.appColors.primary,
                    ),
                  ),

                  SizedBox(width: context.w(10)),
                  SvgPicture.asset(icon ?? AppAssets.nextIcon),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
