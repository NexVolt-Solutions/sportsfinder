import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  final Widget? centerWidget;

  final Widget? leading;

  final Widget? trailing;

  final VoidCallback? onLeadingTap;

  final VoidCallback? onTap;

  final Color? iconColor;

  static const double _kToolbarHeight = 56;
  static const double _kIconSize = 24;

  const AppBarWidget({
    super.key,
    this.title,
    this.centerWidget,
    this.leading,
    this.trailing,
    this.onLeadingTap,
    this.onTap,
    this.iconColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(_kToolbarHeight);

  Widget _buildLeading(BuildContext context) {
    if (leading != null) return leading!;
    final leadingTap = onLeadingTap ?? onTap;
    if (leadingTap != null) {
      return GestureDetector(
        onTap: leadingTap,
        behavior: HitTestBehavior.opaque,
        child: SvgPicture.asset(AppAssets.backIcon, fit: BoxFit.contain),
      );
    }
    return const SizedBox(width: _kIconSize + 24, height: _kIconSize);
  }

  Widget _buildCenter(BuildContext context) {
    if (title != null && title!.isNotEmpty) {
      return Center(
        child: Text(
          title!,
          style: context.appText.text18Bold,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    if (centerWidget != null) return centerWidget!;
    return const SizedBox.shrink();
  }

  Widget _buildTrailing(BuildContext context) {
    if (trailing != null) return trailing!;
    return const SizedBox(width: _kIconSize + 24, height: _kIconSize);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: context.h(20)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildLeading(context),
            Expanded(child: _buildCenter(context)),
            _buildTrailing(context),
          ],
        ),
        SizedBox(height: context.h(20)),
      ],
    );
  }
}
