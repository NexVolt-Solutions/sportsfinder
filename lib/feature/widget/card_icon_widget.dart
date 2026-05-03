import 'package:flutter/foundation.dart' show kIsWeb;
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
    final box = Container(
      padding: context.padAll(kIsWeb ? 12 : 8),
      decoration: BoxDecoration(
        color: isSelected
            ? c.primary
            : (kIsWeb ? const Color(0xFFF2F8FF) : c.surface),
        borderRadius: BorderRadius.circular(context.radius(kIsWeb ? 14 : 12)),
        border: kIsWeb && !isSelected
            ? Border.all(color: const Color(0xFFD7E7F7))
            : null,
      ),
      child: SvgPicture.asset(
        imageAsset,
        width: context.w(kIsWeb ? 22 : 18),
        height: context.w(kIsWeb ? 22 : 18),
        colorFilter: ColorFilter.mode(
          isSelected ? c.onPrimary : c.greyDark,
          BlendMode.srcIn,
        ),
      ),
    );
    if (kIsWeb) {
      return box;
    }
    return Card(color: isSelected ? c.primary : c.surface, child: box);
  }
}
