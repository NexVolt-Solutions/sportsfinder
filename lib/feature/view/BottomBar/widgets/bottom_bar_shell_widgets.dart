import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Network/notification_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Auth/Login/login_viewmodel.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class BottomBarWebMetrics {
  BottomBarWebMetrics._();

  static const double designWidth = 1440;
  static const double designHeight = 1169;
  static const double barHeight = 64;
  static const double barBottomPadding = 4;
  static const double barRadius = 12;
  static const double homeButtonSize = 48;
  static const double webSidebarWidth = 280;
  static const double navIconSize = 22;
  static const double barShadowBlur = 12;
  static const double barShadowOffset = 4;
  static const double navItemIconLabelGap = 2;

  static double scale(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widthScale = size.width / designWidth;
    final heightScale = size.height / designHeight;
    return widthScale < heightScale ? widthScale : heightScale;
  }

  static double w(BuildContext context, double value) => value * scale(context);

  static double h(BuildContext context, double value) => value * scale(context);

  static double bottomChromeHeight(BuildContext context) =>
      barHeight + context.h(4);
}

class BottomBarNotificationBell extends StatelessWidget {
  const BottomBarNotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final unreadCount = context.select<NotificationService, int>(
      (service) => service.notifications.where((item) => !item.isRead).length,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SvgPicture.asset(AppAssets.notificationIcon, fit: BoxFit.contain),
        if (unreadCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: c.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                textAlign: TextAlign.center,
                style: context.appText.text12W500.copyWith(
                  color: c.onPrimary,
                  fontSize: 9,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class BottomBarTopBar extends StatelessWidget {
  const BottomBarTopBar({
    super.key,
    required this.onNotificationTap,
  });

  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.padSym(h: 20),
      child: AppBarWidget(
        leading: NormalText(titleText: AppText.sportFinding, titleFontSize: 18),
        trailing: const BottomBarNotificationBell(),
        onTrailingTap: onNotificationTap,
      ),
    );
  }
}

class BottomBarMobileNavItem extends StatelessWidget {
  const BottomBarMobileNavItem({
    super.key,
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final color = isSelected ? c.primary : c.greyDark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            width: BottomBarWebMetrics.navIconSize,
            height: BottomBarWebMetrics.navIconSize,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          SizedBox(height: BottomBarWebMetrics.navItemIconLabelGap),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.appText.text12W500.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class BottomBarWebNavItem extends StatelessWidget {
  const BottomBarWebNavItem({
    super.key,
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bg = isSelected
        ? c.primary.withValues(alpha: 0.12)
        : Colors.transparent;
    final color = isSelected ? c.primary : c.greyDark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: BottomBarWebMetrics.w(context, 16),
          vertical: BottomBarWebMetrics.h(context, 12),
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(BottomBarWebMetrics.w(context, 14)),
          border: Border.all(
            color: isSelected
                ? c.primary.withValues(alpha: 0.18)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            iconPath == AppAssets.webHomeIcon
                ? SvgPicture.asset(
                    iconPath,
                    width: BottomBarWebMetrics.navIconSize,
                    height: BottomBarWebMetrics.navIconSize,
                  )
                : SvgPicture.asset(
                    iconPath,
                    width: BottomBarWebMetrics.navIconSize,
                    height: BottomBarWebMetrics.navIconSize,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  ),
            SizedBox(width: BottomBarWebMetrics.w(context, 12)),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appText.text14W500.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomBarTabStack extends StatelessWidget {
  const BottomBarTabStack({
    super.key,
    required this.selectedIndex,
    required this.children,
  });

  final int selectedIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: IndexedStack(
        index: selectedIndex.clamp(0, children.length - 1),
        sizing: StackFit.expand,
        children: children,
      ),
    );
  }
}

class BottomBarBottomNav extends StatelessWidget {
  const BottomBarBottomNav({
    super.key,
    required this.viewModel,
  });

  final BottomBarScreenViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BottomBarWebMetrics.barBottomPadding),
      child: SizedBox(
        height: BottomBarWebMetrics.bottomChromeHeight(context),
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: context.sw(20),
              right: context.sw(20),
              bottom: 0,
              height: BottomBarWebMetrics.barHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(
                    context.radius(BottomBarWebMetrics.barRadius),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.blue20,
                      blurRadius: BottomBarWebMetrics.barShadowBlur,
                      offset: const Offset(0, BottomBarWebMetrics.barShadowOffset),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: BottomBarMobileNavItem(
                        iconPath: AppAssets.matchesIcon,
                        label: AppText.match,
                        isSelected: viewModel.selectedIndex == 0,
                        onTap: () => viewModel.setSelectedIndex(0),
                      ),
                    ),
                    Expanded(
                      child: BottomBarMobileNavItem(
                        iconPath: AppAssets.searchBarIcon,
                        label: AppText.discover,
                        isSelected: viewModel.selectedIndex == 1,
                        onTap: () => viewModel.setSelectedIndex(1),
                      ),
                    ),
                    SizedBox(width: context.sw(12)),
                    Expanded(child: SizedBox(width: context.sw(12))),
                    Expanded(
                      child: BottomBarMobileNavItem(
                        iconPath: AppAssets.chatIcon,
                        label: AppText.chat,
                        isSelected: viewModel.selectedIndex == 3,
                        onTap: () => viewModel.setSelectedIndex(3),
                      ),
                    ),
                    Expanded(
                      child: BottomBarMobileNavItem(
                        iconPath: AppAssets.profileIcon,
                        label: AppText.profile,
                        isSelected: viewModel.selectedIndex == 4,
                        onTap: () => viewModel.setSelectedIndex(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: BottomBarWebMetrics.barHeight / 2 -
                  BottomBarWebMetrics.homeButtonSize / 1.1,
              child: GestureDetector(
                onTap: () =>
                    viewModel.setSelectedIndex(BottomBarScreenViewModel.homeIndex),
                child: SvgPicture.asset(AppAssets.homeIcon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomBarWebTopBar extends StatelessWidget {
  const BottomBarWebTopBar({
    super.key,
    required this.viewModel,
    required this.onNotificationTap,
  });

  final BottomBarScreenViewModel viewModel;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final userName = viewModel.userName.trim().isNotEmpty
        ? viewModel.userName.trim()
        : 'User';
    final email = viewModel.userEmail.trim().isNotEmpty
        ? viewModel.userEmail.trim()
        : 'user@sports.com';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BottomBarWebMetrics.w(context, 32),
        vertical: BottomBarWebMetrics.h(context, 22),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: c.greylight.withValues(alpha: 0.4)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: BottomBarTopBar(onNotificationTap: onNotificationTap),
          ),
          SizedBox(width: BottomBarWebMetrics.w(context, 20)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: BottomBarWebMetrics.w(context, 12),
              vertical: BottomBarWebMetrics.h(context, 8),
            ),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border.all(color: c.greylight.withValues(alpha: 0.45)),
              borderRadius: BorderRadius.circular(
                BottomBarWebMetrics.w(context, 24),
              ),
            ),
            child: Row(
              children: [
                AppAvatar(
                  size: BottomBarWebMetrics.w(context, 36),
                  imageUrl: viewModel.userImage,
                  fallbackText: userName,
                ),
                SizedBox(width: BottomBarWebMetrics.w(context, 10)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: context.appText.text14W600.copyWith(
                        color: c.onSurface,
                      ),
                    ),
                    Text(
                      email,
                      style: context.appText.text12W400.copyWith(
                        color: c.greyDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomBarWebSidebar extends StatelessWidget {
  const BottomBarWebSidebar({
    super.key,
    required this.viewModel,
    required this.onLogout,
  });

  final BottomBarScreenViewModel viewModel;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Container(
      width: BottomBarWebMetrics.webSidebarWidth,
      margin: EdgeInsets.fromLTRB(
        BottomBarWebMetrics.w(context, 16),
        BottomBarWebMetrics.h(context, 16),
        BottomBarWebMetrics.w(context, 12),
        BottomBarWebMetrics.h(context, 16),
      ),
      padding: EdgeInsets.fromLTRB(
        BottomBarWebMetrics.w(context, 16),
        BottomBarWebMetrics.h(context, 20),
        BottomBarWebMetrics.w(context, 16),
        BottomBarWebMetrics.h(context, 20),
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(BottomBarWebMetrics.w(context, 24)),
        boxShadow: [
          BoxShadow(
            color: c.blue20,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppText.sportFinding,
            style: context.appText.text18Bold.copyWith(color: c.onSurface),
          ),
          SizedBox(height: BottomBarWebMetrics.h(context, 6)),
          Text(
            'Dashboard',
            style: context.appText.text12W400.copyWith(color: c.greylight),
          ),
          SizedBox(height: BottomBarWebMetrics.h(context, 28)),
          BottomBarWebNavItem(
            iconPath: AppAssets.webHomeIcon,
            label: 'Home',
            isSelected:
                viewModel.selectedIndex == BottomBarScreenViewModel.homeIndex,
            onTap: () =>
                viewModel.setSelectedIndex(BottomBarScreenViewModel.homeIndex),
          ),
          SizedBox(height: BottomBarWebMetrics.h(context, 10)),
          BottomBarWebNavItem(
            iconPath: AppAssets.searchBarIcon,
            label: 'Discover Matches',
            isSelected: viewModel.selectedIndex == 1,
            onTap: () => viewModel.setSelectedIndex(1),
          ),
          SizedBox(height: BottomBarWebMetrics.h(context, 10)),
          BottomBarWebNavItem(
            iconPath: AppAssets.matchesIcon,
            label: 'My Matches',
            isSelected: viewModel.selectedIndex == 0,
            onTap: () => viewModel.setSelectedIndex(0),
          ),
          SizedBox(height: BottomBarWebMetrics.h(context, 10)),
          BottomBarWebNavItem(
            iconPath: AppAssets.chatIcon,
            label: 'Chat',
            isSelected: viewModel.selectedIndex == 3,
            onTap: () => viewModel.setSelectedIndex(3),
          ),
          SizedBox(height: BottomBarWebMetrics.h(context, 10)),
          BottomBarWebNavItem(
            iconPath: AppAssets.profileIcon,
            label: 'Profile',
            isSelected: viewModel.selectedIndex == 4,
            onTap: () => viewModel.setSelectedIndex(4),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onLogout,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: BottomBarWebMetrics.w(context, 14),
                vertical: BottomBarWebMetrics.h(context, 12),
              ),
              decoration: BoxDecoration(
                color: c.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  BottomBarWebMetrics.w(context, 16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: BottomBarWebMetrics.w(context, 18),
                    color: c.error,
                  ),
                  SizedBox(width: BottomBarWebMetrics.w(context, 8)),
                  Text(
                    AppText.logout,
                    style: context.appText.text14W500.copyWith(color: c.error),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomBarWebLayout extends StatelessWidget {
  const BottomBarWebLayout({
    super.key,
    required this.viewModel,
    required this.tabStack,
    required this.onNotificationTap,
    required this.onLogout,
  });

  final BottomBarScreenViewModel viewModel;
  final Widget tabStack;
  final VoidCallback onNotificationTap;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: BottomBarWebMetrics.designWidth,
          maxHeight: BottomBarWebMetrics.designHeight,
        ),
        child: Padding(
          padding: EdgeInsets.all(BottomBarWebMetrics.w(context, 16)),
          child: Row(
            children: [
              BottomBarWebSidebar(
                viewModel: viewModel,
                onLogout: onLogout,
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.appColors.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(
                      BottomBarWebMetrics.w(context, 24),
                    ),
                    border: Border.all(
                      color: context.appColors.greylight.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BottomBarWebTopBar(
                        viewModel: viewModel,
                        onNotificationTap: onNotificationTap,
                      ),
                      tabStack,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> logoutFromBottomBar(BuildContext context) async {
  await LoginScreenViewModel.logout();
  if (!context.mounted) return;
  Navigator.pushNamedAndRemoveUntil(
    context,
    RoutesName.LoginScreen,
    (route) => false,
  );
}
