import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

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
    final c = context.appColors;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: context.sh(48),
            padding: EdgeInsets.symmetric(
              horizontal: context.sw(12),
              vertical: context.sh(10),
            ),
            decoration: BoxDecoration(
              color: c.blue10,
              borderRadius: BorderRadius.circular(context.radiusR(12)),
              border: Border.all(color: c.primary),
            ),
            child: Row(
              children: [
                SvgIconWidget(c: c, icon: AppAssets.searchIcon),
                SizedBox(width: context.sw(12)),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: context.appText.text16W500.copyWith(
                      color: c.onSurface,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: hintText,
                      hintStyle: context.appText.text16W500.copyWith(
                        color: c.greyDark,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          SizedBox(width: context.sw(12)),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(context.radiusR(12)),
              child: Padding(
                padding: context.padSym(h: 12, v: 12),
                child: SvgIconWidget(c: c, icon: AppAssets.filterIcon),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SvgIconWidget extends StatelessWidget {
  const SvgIconWidget({super.key, required this.c, required this.icon});

  final AppColorTheme c;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon,
      width: context.sw(24),
      height: context.sw(24),
      colorFilter: ColorFilter.mode(c.greyDark, BlendMode.srcIn),
    );
  }
}
