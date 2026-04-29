import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/Network/notification_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Chat/chat_list_screen.dart';
import 'package:sport_finding/feature/view/Home/components/all_upcoming_matches.dart';
import 'package:sport_finding/feature/view/Home/viewModel/all_upcomming_matches_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/home_screen_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/upcoming_matches_scope.dart';
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

/// Tab order must match indices used by [BottomBarScreenViewModel] / nav bar.
List<Widget> _bottomBarTabChildren() => <Widget>[
  const _MyMatchesTabSlot(),
  const DiscoverTabScreen(embedInBottomBar: true),
  ChangeNotifierProvider(
    create: (_) => HomeScreenViewModel(
      repository: MyProfileRepository(apiService: ApiService()),
    ),
    child: const HomeScreen(showAppBar: false),
  ),
  const ChatListScreen(embedInBottomBar: true),
  const ProfileScreen(embedInBottomBar: true),
];

class _MyMatchesTabSlot extends StatelessWidget {
  const _MyMatchesTabSlot();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AllUpcommingMatchesViewModel(
        scope: UpcomingMatchesScope.myMatches,
      ),
      child: const _MyMatchesFetchWhenTabSelected(),
    );
  }
}

/// [IndexedStack] builds every tab at once; defer GET /matches until the user
/// opens the My Matches tab so startup does not duplicate Home's request.
class _MyMatchesFetchWhenTabSelected extends StatefulWidget {
  const _MyMatchesFetchWhenTabSelected();

  @override
  State<_MyMatchesFetchWhenTabSelected> createState() =>
      _MyMatchesFetchWhenTabSelectedState();
}

class _MyMatchesFetchWhenTabSelectedState
    extends State<_MyMatchesFetchWhenTabSelected> {
  static const int _myMatchesTabIndex = 0;

  bool _requestedFetch = false;

  @override
  Widget build(BuildContext context) {
    final selected = context.select<BottomBarScreenViewModel, int>(
      (vm) => vm.selectedIndex,
    );

    if (selected == _myMatchesTabIndex && !_requestedFetch) {
      final vm = context.read<AllUpcommingMatchesViewModel>();
      if (!vm.isLoading && vm.allMatches.isEmpty) {
        _requestedFetch = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.read<AllUpcommingMatchesViewModel>().fetchMatches();
        });
      }
    }

    return const AllUpcomingMatches(
      embedAsBottomTab: true,
      listTitle: AppText.myMatches,
    );
  }
}

class _BottomBarContent extends StatefulWidget {
  const _BottomBarContent();

  @override
  State<_BottomBarContent> createState() => _BottomBarContentState();
}

class _BottomBarContentState extends State<_BottomBarContent> {
  static const double _barHeight = 64;
  static const double _barBottomPadding = 4;
  static const double _barRadius = 12;
  static const double _homeButtonSize = 48;
  static const double _webSidebarWidth = 248;
  static const double _navIconSize = 22;
  static const double _barShadowBlur = 12;
  static const double _barShadowOffset = 4;
  static const double _navItemIconLabelGap = 2;

  bool _appliedRouteTab = false;
  bool _requestedInitialNotifications = false;

  late final List<Widget> _tabChildren = _bottomBarTabChildren();

  /// Vertical room for the capsule plus the home control sitting slightly above it.
  static double _bottomChromeHeight(BuildContext context) =>
      _barHeight + context.h(4);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requestedInitialNotifications) {
      _requestedInitialNotifications = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final service = context.read<NotificationService>();
        service.ensureRealtimeConnected();
        if (!service.isLoading && service.notifications.isEmpty) {
          service.fetchNotifications();
        }
      });
    }
    if (_appliedRouteTab) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! int) return;
    _appliedRouteTab = true;
    final maxIndex = _tabChildren.length - 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BottomBarScreenViewModel>().setSelectedIndex(
            args.clamp(0, maxIndex),
          );
    });
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

  Widget _webNavItem({
    required BuildContext context,
    required String iconPath,
    required String label,
    required int index,
    required int selectedIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;
    final c = context.appColors;
    final bg = isSelected ? c.primary.withValues(alpha: 0.12) : Colors.transparent;
    final color = isSelected ? c.primary : c.greyDark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: context.w(16),
          vertical: context.h(12),
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(context.radiusR(14)),
          border: Border.all(
            color: isSelected ? c.primary.withValues(alpha: 0.18) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: _navIconSize,
              height: _navIconSize,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            SizedBox(width: context.w(12)),
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

  Widget _buildNotificationBell(BuildContext context) {
    final c = context.appColors;
    final unreadCount = context.select<NotificationService, int>(
      (service) => service.notifications.where((item) => !item.isRead).length,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SvgPicture.asset(
          AppAssets.notificationIcon,
          fit: BoxFit.contain,
        ),
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

  Future<void> _handleNotificationTap(BuildContext context) async {
    final service = Provider.of<NotificationService>(context, listen: false);
    await service.fetchNotifications();
    if (!context.mounted) return;
    Navigator.pushNamed(context, RoutesName.notificationsScreen);
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: context.padSym(h: 20),
      child: AppBarWidget(
        leading: NormalText(
          titleText: AppText.sportFinding,
          titleFontSize: 18,
        ),
        trailing: _buildNotificationBell(context),
        onTrailingTap: () => _handleNotificationTap(context),
      ),
    );
  }

  Widget _buildTabStack(BottomBarScreenViewModel vm) {
    return Expanded(
      child: IndexedStack(
        index: vm.selectedIndex.clamp(0, _tabChildren.length - 1),
        sizing: StackFit.expand,
        children: _tabChildren,
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, BottomBarScreenViewModel vm) {
    return Padding(
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
                  borderRadius: BorderRadius.circular(context.radiusR(_barRadius)),
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
                onTap: () => vm.setSelectedIndex(BottomBarScreenViewModel.homeIndex),
                child: SvgPicture.asset(AppAssets.homeIcon),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebSidebar(BuildContext context, BottomBarScreenViewModel vm) {
    final c = context.appColors;

    return Container(
      width: _webSidebarWidth,
      margin: EdgeInsets.fromLTRB(
        context.w(16),
        context.h(16),
        context.w(12),
        context.h(16),
      ),
      padding: EdgeInsets.fromLTRB(
        context.w(16),
        context.h(20),
        context.w(16),
        context.h(20),
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(context.radiusR(24)),
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
          SizedBox(height: context.h(6)),
          Text(
            'Dashboard',
            style: context.appText.text12W400.copyWith(color: c.greylight),
          ),
          SizedBox(height: context.h(28)),
          _webNavItem(
            context: context,
            iconPath: AppAssets.matchesIcon,
            label: AppText.match,
            index: 0,
            selectedIndex: vm.selectedIndex,
            onTap: () => vm.setSelectedIndex(0),
          ),
          SizedBox(height: context.h(10)),
          _webNavItem(
            context: context,
            iconPath: AppAssets.searchBarIcon,
            label: AppText.discover,
            index: 1,
            selectedIndex: vm.selectedIndex,
            onTap: () => vm.setSelectedIndex(1),
          ),
          SizedBox(height: context.h(10)),
          _webNavItem(
            context: context,
            iconPath: AppAssets.homeIcon,
            label: 'Home',
            index: BottomBarScreenViewModel.homeIndex,
            selectedIndex: vm.selectedIndex,
            onTap: () => vm.setSelectedIndex(BottomBarScreenViewModel.homeIndex),
          ),
          SizedBox(height: context.h(10)),
          _webNavItem(
            context: context,
            iconPath: AppAssets.chatIcon,
            label: AppText.chat,
            index: 3,
            selectedIndex: vm.selectedIndex,
            onTap: () => vm.setSelectedIndex(3),
          ),
          SizedBox(height: context.h(10)),
          _webNavItem(
            context: context,
            iconPath: AppAssets.profileIcon,
            label: AppText.profile,
            index: 4,
            selectedIndex: vm.selectedIndex,
            onTap: () => vm.setSelectedIndex(4),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(14),
              vertical: context.h(12),
            ),
            decoration: BoxDecoration(
              color: c.blue10,
              borderRadius: BorderRadius.circular(context.radiusR(16)),
            ),
            child: Text(
              'Web dashboard mode',
              style: context.appText.text12W500.copyWith(color: c.greyDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, BottomBarScreenViewModel vm) {
    return Row(
      children: [
        _buildWebSidebar(context, vm),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              0,
              context.h(16),
              context.w(16),
              context.h(16),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.appColors.surface.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(context.radiusR(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopBar(context),
                  _buildTabStack(vm),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<BottomBarScreenViewModel>(
        builder: (context, vm, _) => MainFrame(
          child: kIsWeb
              ? _buildWebLayout(context, vm)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopBar(context),
                    _buildTabStack(vm),
                    _buildBottomNav(context, vm),
                  ],
                ),
        ),
      ),
    );
  }
}
