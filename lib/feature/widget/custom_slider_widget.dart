import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class CustomSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const CustomSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: context.h(12),
        activeTrackColor: context.appColors.blue20,
        inactiveTrackColor: context.appColors.blue10,
        thumbColor: context.appColors.primary,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        overlayShape: SliderComponentShape.noOverlay,
      ),
      child: Column(
        children: [
          Slider(value: value, min: min, max: max, onChanged: onChanged),
          SizedBox(height: context.h(4)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NormalText(
                titleText: '${value.toInt()} km', // 🔥 dynamic value
                titleColor: context.appColors.greylight,
              ),
              NormalText(
                titleText: AppText.anyKm,
                titleColor: context.appColors.greylight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
