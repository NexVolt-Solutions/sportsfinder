import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

/// Custom app bar matching the design: black background, optional leading/trailing,
/// center as title text or a widget (e.g. logo/SVG). Pixel-perfect layout.
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  /// Center title text. Ignored if [centerWidget] is non-null.
  final String? title;

  /// Center widget when [title] is null (e.g. logo, SVG, Image.asset).
  final Widget? centerWidget;

  /// Leading widget (e.g. back chevron). If null and [onLeadingTap] is set, shows default back icon.
  final Widget? leading;

  /// Trailing widget (e.g. bell, share icon). Optional.
  final Widget? trailing;

  /// When set and [leading] is null, shows default back icon and calls this on tap.
  final VoidCallback? onLeadingTap;

  /// Backward compatibility: same as [onLeadingTap].
  final VoidCallback? onTap;

  final Color? backgroundColor;
  final Color? iconColor;
  final Color? titleColor;

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
    this.backgroundColor,
    this.iconColor,
    this.titleColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(_kToolbarHeight);

  Widget _buildLeading(BuildContext context) {
    if (leading != null) return leading!;
    final leadingTap = onLeadingTap ?? onTap;
    final colors = context.appColors;
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
              iconColor ?? colors.greyDark,
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
    final colors = context.appColors;
    if (title != null && title!.isNotEmpty) {
      return Center(
        child: Text(
          title!,
          style: context.appText.text18Bold.copyWith(
            color: titleColor ?? colors.onPrimary,
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
    final colors = context.appColors;
    return Container(
      height: _kToolbarHeight,
      padding: EdgeInsets.only(
        left: context.sw(_kHorizontalPadding),
        right: context.sw(_kHorizontalPadding),
      ),
      color: backgroundColor ?? AppColors.transparent,
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
