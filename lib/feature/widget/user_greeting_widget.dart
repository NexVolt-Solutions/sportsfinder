import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class UserGreetingWidget extends StatelessWidget {
  final String title;
  final String? subTitle;
  final String locName;
  final bool isShow;
  final String? imageUrl;

  const UserGreetingWidget({
    super.key,
    required this.title,
    this.subTitle,
    required this.locName,
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
              NormalText(
                subText: locName,
                maxLines: 2,
                subStyle: context.appText.text14W500,
              ),

              // ✅ Conditional show here
              if (isShow && subTitle != null && subTitle!.isNotEmpty)
                NormalText(
                  titleText: subTitle!,
                  maxLines: 2,
                  titleStyle: context.appText.text12W400,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
