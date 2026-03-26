import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

// class UserGreetingWidget extends StatelessWidget {
//   final String title;
//   final String title2;
//   final String name;
//   final String? imageUrl; // 👈 optional image

//   const UserGreetingWidget({
//     super.key,
//     required this.title,
//     required this.name,
//     this.imageUrl,
//     required this.title2,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         // 👇 Profile Image
//         CircleAvatar(
//           radius: 25,
//           backgroundColor: context.appColors.greyDark,
//           backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
//               ? NetworkImage(imageUrl!)
//               : null,
//           child: (imageUrl == null || imageUrl!.isEmpty)
//               ? Icon(Icons.person, color: context.appColors.white)
//               : null,
//         ),

//         SizedBox(width: context.w(16)),

//         // 👇 Text
//         Expanded(
//           child: NormalText(titleText: title, subText: name),
//         ),
//         Expanded(child: NormalText(titleText: title2)),
//       ],
//     );
//   }
// }
class UserGreetingWidget extends StatelessWidget {
  final String title;
  final String? title2;
  final String name;
  final bool isShow;
  final String? imageUrl;

  const UserGreetingWidget({
    super.key,
    required this.title,
    this.title2,
    required this.name,
    this.imageUrl,
    this.isShow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 👇 Profile Image
        CircleAvatar(
          radius: context.radiusR(22),
          backgroundColor: context.appColors.greyDark,
          backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
              ? NetworkImage(imageUrl!)
              : null,
          child: (imageUrl == null || imageUrl!.isEmpty)
              ? Icon(Icons.person, color: context.appColors.white)
              : null,
        ),

        SizedBox(width: context.w(16)),

        // 👇 All text inside Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NormalText(titleText: title),
              NormalText(subText: name),

              // ✅ Conditional show here
              if (isShow && title2 != null && title2!.isNotEmpty)
                NormalText(
                  titleText: title2!,
                  titleColor: context.appColors.greylight,
                  subFontSize: 12,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
