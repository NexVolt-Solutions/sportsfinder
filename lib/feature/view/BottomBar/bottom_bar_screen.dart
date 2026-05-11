import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/chat_route_args.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Network/notification_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Chat/chat_list_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/profile_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_list_screen_view_model.dart';
import 'package:sport_finding/feature/view/BottomBar/widgets/bottom_bar_shell_widgets.dart';
import 'package:sport_finding/feature/view/Discover/discover_tab_screen.dart';
import 'package:sport_finding/feature/view/Home/components/all_upcoming_matches.dart';
import 'package:sport_finding/feature/view/Home/home_screen.dart';
import 'package:sport_finding/feature/view/Home/viewModel/all_upcomming_matches_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/home_screen_view_model.dart';
import 'package:sport_finding/feature/view/Home/viewModel/upcoming_matches_scope.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/webwidget/web_home_content.dart';

class BottomBarScreen extends StatelessWidget {
  const BottomBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BottomBarContent();
  }
}

// (moved into _BottomBarContentState to support responsive layouts)

class _MyMatchesTabSlot extends StatelessWidget {
  const _MyMatchesTabSlot({required this.forceMobileLayout});

  final bool forceMobileLayout;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          AllUpcommingMatchesViewModel(scope: UpcomingMatchesScope.myMatches),
      child: _MyMatchesFetchWhenTabSelected(forceMobileLayout: forceMobileLayout),
    );
  }
}

class _MyMatchesFetchWhenTabSelected extends StatefulWidget {
  const _MyMatchesFetchWhenTabSelected({required this.forceMobileLayout});

  final bool forceMobileLayout;

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

    return AllUpcomingMatches(
      embedAsBottomTab: true,
      listTitle: AppText.myMatches,
      forceMobileLayout: widget.forceMobileLayout,
    );
  }
}

class _BottomBarContent extends StatefulWidget {
  const _BottomBarContent();

  @override
  State<_BottomBarContent> createState() => _BottomBarContentState();
}

class _BottomBarContentState extends State<_BottomBarContent> {
  static const int _chatTabIndex = 3;
  static const double _webToMobileBreakpoint = 980;
  bool _appliedRouteTab = false;
  bool _requestedInitialNotifications = false;
  bool _requestedInitialProfile = false;

  List<Widget> _tabChildren({required bool forceMobileLayout}) => <Widget>[
        _MyMatchesTabSlot(forceMobileLayout: forceMobileLayout),
        DiscoverTabScreen(
          embedInBottomBar: true,
          forceMobileLayout: forceMobileLayout,
        ),
        ChangeNotifierProvider(
          create: (_) => HomeScreenViewModel(),
          child: kIsWeb && !forceMobileLayout
              ? Consumer<HomeScreenViewModel>(
                  builder: (context, model, _) => WebHomeContent(model: model),
                )
              : const HomeScreen(),
        ),
        const ChatListScreen(embedInBottomBar: true),
        const ProfileScreen(embedInBottomBar: true),
      ];

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
    // Tab count is stable regardless of responsive layout.
    const maxIndex = 4;
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

  Future<void> _pickAndOpenUserForChat(BuildContext context) async {
    final selected = await Navigator.pushNamed(
      context,
      RoutesName.allMemberScreen,
    );
    if (!context.mounted || selected is! ChatRouteArgs) return;

    final selectedName = selected.contactName.trim();
    final selectedTargetUserId = (selected.targetUserId ?? '').trim();
    if (selectedName.isEmpty || selectedTargetUserId.isEmpty) return;

    ChatListScreenViewModel.upsertThread(
      userName: selectedName,
      targetUserId: selectedTargetUserId,
      lastMessage: 'Chat started',
      lastAt: DateTime.now(),
      unreadCount: 0,
      isOnline: true,
    );

    await Navigator.pushNamed(
      context,
      RoutesName.chatScreen,
      arguments: selected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
     
       body: Consumer<BottomBarScreenViewModel>(
        builder: (context, vm, _) => MainFrame(
          showDecorationLayer: !kIsWeb,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final useMobileChrome = width < _webToMobileBreakpoint;
              final tabChildren = _tabChildren(forceMobileLayout: kIsWeb && useMobileChrome);

              final tabStack = BottomBarTabStack(
                selectedIndex: vm.selectedIndex,
                children: tabChildren,
              );

              if (kIsWeb && !useMobileChrome) {
                return BottomBarWebLayout(
                  viewModel: vm,
                  tabStack: tabStack,
                  onNotificationTap: () => _handleNotificationTap(context),
                  onLogout: () => logoutFromBottomBar(context),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BottomBarTopBar(
                    onNotificationTap: () => _handleNotificationTap(context),
                  ),
                  tabStack,
                  BottomBarBottomNav(viewModel: vm),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
