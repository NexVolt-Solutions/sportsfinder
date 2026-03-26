import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class PlayerCountWidget extends StatelessWidget {
  final int playerNo1;
  final int playerNo2;
  const PlayerCountWidget({
    super.key,
    required this.playerNo1,
    required this.playerNo2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          height: 25,
          child: Stack(
            children: [
              _avatar(left: 0, context: context),
              _avatar(left: 20, context: context),
              _avatar(left: 40, context: context),
            ],
          ),
        ),
        NormalText(
          titleText: '$playerNo1',
          titleColor: context.appColors.greyDark,
          titleStyle: context.appText.text12W600,
        ),
        NormalText(
          titleText: '/$playerNo2',
          titleColor: context.appColors.greyDark,
          titleStyle: context.appText.text12W600,
        ),
      ],
    );
  }

  Widget _avatar({required double left, required BuildContext context}) {
    return Positioned(
      left: left,
      child: Container(
        padding: context.padAll(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.appColors.onPrimary,
          boxShadow: [
            BoxShadow(
              color: context.appColors.greyDark,
              offset: const Offset(0, 4),
              blurRadius: 60,
              blurStyle: BlurStyle.inner,
            ),
          ],
        ),
        child: const Icon(Icons.person, size: 16, color: Colors.black54),
      ),
    );
  }
}
