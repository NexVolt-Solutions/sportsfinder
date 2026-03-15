import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
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
  static const double _kHorizontalPadding = 16;
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            AppAssets.backIcon,
            width: _kIconSize,
            height: _kIconSize,
            colorFilter: ColorFilter.mode(
              iconColor ?? context.appColors.greyDark,
              BlendMode.srcIn,
            ),
            fit: BoxFit.contain,
          ),
        ),
      );
    }
    return const SizedBox(width: _kIconSize + 24, height: _kIconSize);
  }

  Widget _buildCenter(BuildContext context) {
    if (title != null && title!.isNotEmpty) {
      return Center(
        child: Text(
          title!,
          style: context.appText.text16Bold.copyWith(
            color: context.appColors.onSurface,
          ),
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
    return Container(
      height: _kToolbarHeight,
      padding: EdgeInsets.only(
        left: context.sw(_kHorizontalPadding),
        right: context.sw(_kHorizontalPadding),
      ),
      color: AppColors.transparent,
      child: Row(
        children: [
          _buildLeading(context),
          Expanded(child: _buildCenter(context)),
          _buildTrailing(context),
        ],
      ),
    );
  }
}
