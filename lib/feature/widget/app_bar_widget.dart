import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class AppBarWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final VoidCallback? onHeartTap;

  const AppBarWidget({
    super.key,
    required this.title,
    this.onTap,
    this.onHeartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.sh(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          onTap != null
              ? GestureDetector(
                  onTap: onTap,
                  child: Center(
                    child: SvgPicture.asset(
                      AppAssets.backIcon,
                      fit: BoxFit.scaleDown,
                      placeholderBuilder: (context) =>
                          Icon(Icons.arrow_back, color: AppColors.greydark),
                    ),
                  ),
                )
              : SizedBox(height: context.sh(40), width: context.sw(40)),

          /// 🏷 Title
          Expanded(
            child: Center(
              child: NormalText(
                titleText: title,
                titleSize: context.sp(20),
                titleWeight: FontWeight.w600,
                titleColor: AppColors.blackcolor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
