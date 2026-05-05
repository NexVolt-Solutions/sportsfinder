import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Network/notification_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Chat/chat_list_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/profile_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/view/BottomBar/widgets/bottom_bar_shell_widgets.dart';
import 'package:sport_finding/feature/view/Discover/discover_tab_screen.dart';
import 'package:sport_finding/feature/view/Home/components/all_upcoming_matches.dart';
import 'package:sport_finding/feature/view/Home/home_screen.dart';
import 'package:sport_finding/feature/view/Home/viewModel/all_upcomming_matches_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/home_screen_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/upcoming_matches_scope.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';

class BottomBarScreen extends StatelessWidget {
  const BottomBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BottomBarContent();
  }
}

List<Widget> _bottomBarTabChildren() => <Widget>[
  const _MyMatchesTabSlot(),
  const DiscoverTabScreen(embedInBottomBar: true),
  ChangeNotifierProvider(
    create: (_) => HomeScreenViewModel(),
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
      create: (_) =>
          AllUpcommingMatchesViewModel(scope: UpcomingMatchesScope.myMatches),
      child: const _MyMatchesFetchWhenTabSelected(),
    );
  }
}

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
  bool _appliedRouteTab = false;
  bool _requestedInitialNotifications = false;
  bool _requestedInitialProfile = false;

  late final List<Widget> _tabChildren = _bottomBarTabChildren();

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
    if (kIsWeb && !_requestedInitialProfile) {
      _requestedInitialProfile = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<BottomBarScreenViewModel>().fetchMyProfile();
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

  Future<void> _handleNotificationTap(BuildContext context) async {
    final service = Provider.of<NotificationService>(context, listen: false);
    await service.fetchNotifications();
    if (!context.mounted) return;
    Navigator.pushNamed(context, RoutesName.notificationsScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<BottomBarScreenViewModel>(
        builder: (context, vm, _) => MainFrame(
          showDecorationLayer: !kIsWeb,
          child: kIsWeb
              ? BottomBarWebLayout(
                  viewModel: vm,
                  tabStack: BottomBarTabStack(
                    selectedIndex: vm.selectedIndex,
                    children: _tabChildren,
                  ),
                  onNotificationTap: () => _handleNotificationTap(context),
                  onLogout: () => logoutFromBottomBar(context),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BottomBarTopBar(
                      onNotificationTap: () => _handleNotificationTap(context),
                    ),
                    BottomBarTabStack(
                      selectedIndex: vm.selectedIndex,
                      children: _tabChildren,
                    ),
                    BottomBarBottomNav(viewModel: vm),
                  ],
                ),
        ),
      ),
    );
  }
}
