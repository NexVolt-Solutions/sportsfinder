import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';
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
    return Row(mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(
          size: context.w(44),
          imageUrl: imageUrl,
          fallbackText: title,
          backgroundColor: context.appColors.white,
          iconColor: context.appColors.white,
        ),
        SizedBox(width: context.w(16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NormalText(titleText: title, titleStyle: context.appText.text16W600),
              NormalText(
                subText: locName,
                maxLines: 2,
                subStyle: context.appText.text14W600,
              ),
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
