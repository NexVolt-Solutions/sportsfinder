import 'package:flutter/material.dart';
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
