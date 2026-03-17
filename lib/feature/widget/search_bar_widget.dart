import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: context.padSym(h: 12),
      decoration: BoxDecoration(
        color: c.blue10,
        borderRadius: BorderRadius.circular(context.radiusR(12)),
        border: Border.all(color: c.primary, width: 1.2),
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: c.greyDark),
          hintText: "Search sports or locations...",
          hintStyle: context.appText.text14W400.copyWith(color: c.greyDark),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
