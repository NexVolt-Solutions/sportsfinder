import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Chat/chat_list_screen.dart';
import 'package:sport_finding/feature/view/Home/components/all_upcoming_matches.dart';
import 'package:sport_finding/feature/view/Home/viewModel/all_upcomming_matches_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/home_screen_view_model.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/profile_screen.dart';
import 'package:sport_finding/feature/view/Home/home_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/view/Discover/discover_tab_screen.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

import '../../../Data/Repositories/my_profile_Repository.dart'
    show MyProfileRepository;

class BottomBarScreen extends StatelessWidget {
  const BottomBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BottomBarContent();
  }
}

class _MyMatchesTabSlot extends StatelessWidget {
  const _MyMatchesTabSlot();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AllUpcommingMatchesViewModel()..fetchMatches(),
      child: const AllUpcomingMatches(
        embedAsBottomTab: true,
        listTitle: AppText.myMatches,
      ),
    );
  }
}

class _BottomBarContent extends StatelessWidget {
  const _BottomBarContent();

  static const double _barHeight = 64;
  static const double _barBottomPadding = 4;
  static const double _barRadius = 12;
  static const double _homeButtonSize = 48;
  static const double _navIconSize = 22;
  static const double _barShadowBlur = 12;
  static const double _barShadowOffset = 4;
  static const double _navItemIconLabelGap = 2;

  /// Vertical room for the capsule plus the home control sitting slightly above it.
  static double _bottomChromeHeight(BuildContext context) =>
      _barHeight + context.h(4);

  // bottom_bar_screen.dart
  static final List<Widget> _tabChildren = <Widget>[
    const _MyMatchesTabSlot(),
    const DiscoverTabScreen(embedInBottomBar: true),
    ChangeNotifierProvider(
      create: (_) => HomeScreenViewModel(
        repository: MyProfileRepository(apiService: ApiService()),
      ),
      child: const HomeScreen(showAppBar: false), // ✅ add const
    ),
    const ChatListScreen(embedInBottomBar: true),
    const ProfileScreen(embedInBottomBar: true),
  ];

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
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<BottomBarScreenViewModel>(
        builder: (context, vm, _) => MainFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: context.padSym(h: 20),
                child: AppBarWidget(
                  leading: NormalText(
                    titleText: AppText.sportFinding,
                    titleFontSize: 18,
                  ),

                  onTrailingTap: () => Navigator.pushNamed(
                    context,
                    RoutesName.notificationsScreen,
                  ),
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: vm.selectedIndex.clamp(0, _tabChildren.length - 1),
                  sizing: StackFit.expand,
                  children: _tabChildren,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: _barBottomPadding),
                child: SizedBox(
                  height: _bottomChromeHeight(context),
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        left: context.sw(20),
                        right: context.sw(20),
                        bottom: 0,
                        height: _barHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.appColors.surface,
                            borderRadius: BorderRadius.circular(
                              context.radiusR(_barRadius),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: context.appColors.blue20,
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
                                  label: AppText.match,
                                  index: 0,
                                  selectedIndex: vm.selectedIndex,
                                  onTap: () => vm.setSelectedIndex(0),
                                ),
                              ),
                              Expanded(
                                child: _navItem(
                                  context: context,
                                  iconPath: AppAssets.searchBarIcon,
                                  label: AppText.discover,
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
                                  label: AppText.chat,
                                  index: 3,
                                  selectedIndex: vm.selectedIndex,
                                  onTap: () => vm.setSelectedIndex(3),
                                ),
                              ),
                              Expanded(
                                child: _navItem(
                                  context: context,
                                  iconPath: AppAssets.profileIcon,
                                  label: AppText.profile,
                                  index: 4,
                                  selectedIndex: vm.selectedIndex,
                                  onTap: () => vm.setSelectedIndex(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: _barHeight / 2 - _homeButtonSize / 1.1,
                        child: GestureDetector(
                          onTap: () => vm.setSelectedIndex(
                            BottomBarScreenViewModel.homeIndex,
                          ),
                          child: SvgPicture.asset(AppAssets.homeIcon),
                        ),
                      ),
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
