import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  final Widget? centerWidget;

  final Widget? leading;

  final Widget? trailing;

  final VoidCallback? onLeadingTap;
  final VoidCallback? onTrailingTap;

  final VoidCallback? onTapFirst;
  final VoidCallback? onTapLast;

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
    this.onTapFirst,
    this.iconColor,
    this.onTrailingTap,
    this.onTapLast,
  });

  @override
  Size get preferredSize => const Size.fromHeight(_kToolbarHeight);

  Widget _buildLeading(BuildContext context) {
    if (leading != null) return leading!;
    final leadingTap = onLeadingTap ?? onTapFirst;
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
        child: NormalText(
          titleText: title ?? AppText.sportFinding,
          titleFontSize: 18,
        ),
      );
    }
    if (centerWidget != null) return centerWidget!;
    return const SizedBox.shrink();
  }

  Widget _buildTrailing(BuildContext context) {
    final trailingTap = onTrailingTap ?? onTapLast;

    if (trailing != null) {
      // If custom trailing widget is provided with a tap callback, wrap it
      if (trailingTap != null) {
        return GestureDetector(
          onTap: trailingTap,
          behavior: HitTestBehavior.opaque,
          child: trailing!,
        );
      }
      return trailing!;
    }

    if (trailingTap != null) {
      return GestureDetector(
        onTap: trailingTap,
        behavior: HitTestBehavior.opaque,
        child: SvgPicture.asset(
          AppAssets.notificationIcon,
          fit: BoxFit.contain,
        ),
      );
    }
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
