import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class ProfileCardWidget extends StatelessWidget {
  final String? image1;
  final String? image2;
  final String? title;
  final String? subTitle;

  const ProfileCardWidget({
    super.key,
    this.image1,
    this.image2,
    this.title,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: c.blue10,
        borderRadius: BorderRadius.circular(context.radius(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              SvgPicture.asset(image1 ?? '', fit: BoxFit.scaleDown),
              SizedBox(width: context.w(24)),
              Column(
                children: [
                  NormalText(
                    titleText: title ?? '',
                    titleStyle: context.appText.text16W500,
                    titleColor: c.onSurface,
                    subText: subTitle ?? '',
                    subStyle: context.appText.text14W400,
                    subColor: c.greyDark,
                  ),
                ],
              ),
            ],
          ),
          SvgPicture.asset(image2 ?? '', fit: BoxFit.scaleDown),
        ],
      ),
    );
  }
}

class BottomBarWidget extends StatelessWidget {
  final String? image;
  final String? text;
  const BottomBarWidget({super.key, this.image, this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(image ?? '', fit: BoxFit.scaleDown),
        Text(text ?? '', style: context.appText.text12W400),
      ],
    );
  }
}
