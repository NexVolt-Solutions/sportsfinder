import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class GmailButton extends StatelessWidget {
  const GmailButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.padSym(v: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.radiusR(12)),
        border: Border.all(color: AppColors.bluecolor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(AppAssets.gmailIcon, fit: BoxFit.contain),
          SizedBox(width: context.w(12)),
          Text(
            AppText.continueWithGoogle,
            style: TextStyle(
              color: AppColors.bluecolor,
              fontSize: context.text(14),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
