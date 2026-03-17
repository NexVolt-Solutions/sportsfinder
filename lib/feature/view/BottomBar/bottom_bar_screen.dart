import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view_model/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/view/Discover/discover_tab_screen.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';

class BottomBarScreen extends StatelessWidget {
  const BottomBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BottomBarContent();
  }
}

class _BottomBarContent extends StatelessWidget {
  const _BottomBarContent();

  static const double _barHeight = 64;
  static const double _barBottomPadding = 20;
  static const double _barRadius = 8;
  static const double _homeButtonSize = 48;
  static const double _navIconSize = 22;
  static const double _barShadowBlur = 12;
  static const double _barShadowOffset = 4;
  static const double _navItemIconLabelGap = 2;

  Widget _body(BuildContext context, int selectedIndex) {
    final style = context.appText.text16W500;
    switch (selectedIndex) {
      case 0:
        return Center(child: Text(AppText.navMatches, style: style));
      case 1:
        return const DiscoverTabScreen();
      case 2:
        return Center(child: Text(AppText.navHome, style: style));
      case 3:
        return Center(child: Text(AppText.navChat, style: style));
      case 4:
        return Center(child: Text(AppText.navProfile, style: style));
      default:
        return Center(child: Text(AppText.navHome, style: style));
    }
  }

  Widget _navItem({
    required BuildContext context,
    required String iconPath,
    required String label,
    required int index,
    required int selectedIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;
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
            width: _navIconSize,
            height: _navIconSize,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          SizedBox(height: _navItemIconLabelGap),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BottomBarScreenViewModel>(
        builder: (_, vm, _) =>
            MainFrame(child: _body(context, vm.selectedIndex)),
      ),
      bottomNavigationBar: Consumer<BottomBarScreenViewModel>(
        builder: (_, vm, _) {
          final bottomPadding = MediaQuery.of(context).padding.bottom;
          return Padding(
            padding: EdgeInsets.only(
              bottom: bottomPadding + _barBottomPadding,
              top: _barBottomPadding,
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                // Main capsule bar — fixed height for consistent look
                Container(
                  height: _barHeight,
                  padding: context.padSym(v: 8, h: 12),
                  margin: context.padSym(h: 12),
                  decoration: BoxDecoration(
                    color: context.appColors.blue10,
                    borderRadius: BorderRadius.circular(
                      context.radiusR(_barRadius),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.appColors.blue10,
                        blurRadius: _barShadowBlur,
                        offset: const Offset(0, _barShadowOffset),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _navItem(
                          context: context,
                          iconPath: AppAssets.matchesIcon,
                          label: AppText.navMatches,
                          index: 0,
                          selectedIndex: vm.selectedIndex,
                          onTap: () => vm.setSelectedIndex(0),
                        ),
                      ),
                      Expanded(
                        child: _navItem(
                          context: context,
                          iconPath: AppAssets.searchBarIcon,
                          label: AppText.navDiscover,
                          index: 1,
                          selectedIndex: vm.selectedIndex,

                          onTap: () => vm.setSelectedIndex(1),
                        ),
                      ),
                      SizedBox(width: context.sw(12)),
                      Expanded(child: SizedBox(width: context.sw(12))),
                      Expanded(
                        child: _navItem(
                          context: context,
                          iconPath: AppAssets.chatIcon,
                          label: AppText.navChat,
                          index: 3,
                          selectedIndex: vm.selectedIndex,
                          onTap: () => vm.setSelectedIndex(3),
                        ),
                      ),
                      Expanded(
                        child: _navItem(
                          context: context,
                          iconPath: AppAssets.profileIcon,
                          label: AppText.navProfile,
                          index: 4,
                          selectedIndex: vm.selectedIndex,
                          onTap: () => vm.setSelectedIndex(4),
                        ),
                      ),
                    ],
                  ),
                ),
                // Center Home button (centered, slightly above bar)
                Positioned(
                  bottom: _barHeight / 2 - _homeButtonSize / 1.1,
                  child: GestureDetector(
                    onTap: () =>
                        vm.setSelectedIndex(BottomBarScreenViewModel.homeIndex),
                    child: SvgPicture.asset(AppAssets.homeIcon),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
