import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view/Discover/viewModel/discovery_tab_view_model.dart';

class SportFilterSection extends StatelessWidget {
  const SportFilterSection({
    super.key,
    required this.chips,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<SportFilterChip> chips;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.sh(40),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: chips.length,
        separatorBuilder: (_, _) => SizedBox(width: context.sw(4)),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final isSelected = selectedIndex == index;
          final c = context.appColors;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Card(
              surfaceTintColor: c.blue10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.radius(12)),
                side: BorderSide(
                  color: isSelected ? c.primary : c.transparent,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: context.padSym(h: context.sw(18), v: context.sh(4)),
                child: Text(
                  chip.label,
                  style: context.appText.text14W400.copyWith(
                    color: isSelected ? c.primary : c.onSurface,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
