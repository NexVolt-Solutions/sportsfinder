import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_form_field_layout.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';

/// Reusable search field for the Discover tab: search icon, hint, optional filter button.
class DiscoverySearchField extends StatelessWidget {
  const DiscoverySearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onFilterTap,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
     return SearchBarWidget(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      onFilterTap: onFilterTap,
    );
     }
}

 