import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
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
    final c = context.appColors;
    return Card(
      child: Container(
        padding: context.padAll(8),
        decoration: BoxDecoration(
          color: isSelected ? c.primary : c.surface,
          borderRadius: BorderRadius.circular(context.radiusR(12)),
        ),
        child: SvgPicture.asset(
          imageAsset,
          colorFilter: ColorFilter.mode(
            isSelected ? c.onPrimary : c.greyDark,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
