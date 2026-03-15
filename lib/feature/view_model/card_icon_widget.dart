// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:sport_finding/core/Constants/app_colors.dart';
// import 'package:sport_finding/core/Constants/size_extension.dart';

// class CardIconWidget extends StatelessWidget {
//   final String imageAsset;
//   final bool isSelected;

//   const CardIconWidget({
//     super.key,
//     required this.imageAsset,
//     this.isSelected = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: context.padAll(10),
//       decoration: BoxDecoration(
//         color: isSelected ? AppColors.bluecolor : AppColors.whitecolor,
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.greylight60,
//             offset: Offset(0, 4),
//             blurRadius: 95,
//             blurStyle: BlurStyle.inner,
//           ),
//         ],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: SvgPicture.asset(imageAsset),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class CardIconWidget extends StatelessWidget {
  final String imageAsset;
  final bool isSelected;

  const CardIconWidget({
    super.key,
    required this.imageAsset,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.padAll(8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.bluecolor : AppColors.whitecolor,
        borderRadius: BorderRadius.circular(context.radiusR(12)),

        boxShadow: [
          BoxShadow(
            color: AppColors.greylight60,
            offset: Offset(0, 4),
            blurRadius: 95,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: SvgPicture.asset(
        imageAsset,
        colorFilter: ColorFilter.mode(
          isSelected ? Colors.white : AppColors.greydark,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
