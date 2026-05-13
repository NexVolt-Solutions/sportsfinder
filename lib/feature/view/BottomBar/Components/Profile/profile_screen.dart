import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/Repositories/Logout/logout_repository.dart';
import 'package:sport_finding/Data/model/Logout/logout_model.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/core.dart';
import 'package:sport_finding/core/Network/fcm_service.dart';
import 'package:sport_finding/core/Network/notification_service.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/core/utils/edit_profile_sports_mapping.dart';
import 'package:sport_finding/core/utils/share_sheet_helper.dart';
import 'package:sport_finding/Data/model/edit_profile_route_args.dart';
import 'package:sport_finding/Data/model/follow_connections_args.dart';
import 'package:sport_finding/Data/model/public_profile_args.dart';
import 'package:sport_finding/core/Network/list_of_all_user_service.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/followers_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/following_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/private_profile_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/public_profile_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';
import 'package:sport_finding/feature/view/Legal/privacy_policy_screen.dart';
import 'package:sport_finding/feature/view/Legal/terms_of_service_screen.dart';
import 'package:sport_finding/feature/view/Auth/Login/login_viewmodel.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/profile_detail_widgets.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/profile_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/custom_seeting_card.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/shimmer_loading.dart';
import 'package:sport_finding/feature/widget/user_greeting_widget.dart';
import 'package:sport_finding/feature/widget/app_dialog.dart';

/// Same breakpoint as chat / bottom-bar “desktop” chrome ([ChatListScreen]).
const int _kProfileWebSplitBreakpointPx = 980;

enum _WebProfileShellDetail { public, private, terms, privacy, followers, following }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.embedInBottomBar = false,
    this.forceMobileLayout = false,
  });

  final bool embedInBottomBar;

  /// When true (narrow web with bottom-bar mobile chrome), profile settings use
  /// full-screen routes — same as native — instead of the wide-web split pane.
  final bool forceMobileLayout;

  /// Returns a valid http URL or null — prevents passing placeholder
  /// strings like "default avatar url" to Image.network.
  static String? _safeAvatarUrl(String? raw) => normalizeImageUrl(raw);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  _WebProfileShellDetail? _webShellDetail;
  bool _shellResetScheduled = false;

  void _closeWebShell() {
    if (_webShellDetail == null) return;
    setState(() => _webShellDetail = null);
  }

  bool _useWebProfileSplit(BuildContext context) {
    if (!kIsWeb) return false;
    if (widget.forceMobileLayout) return false;
    return widget.embedInBottomBar &&
        MediaQuery.sizeOf(context).width >= _kProfileWebSplitBreakpointPx;
  }

  void _maybeResetWebShell(BuildContext context, int bottomBarTabIndex) {
    if (_webShellDetail == null || _shellResetScheduled) return;
    final split = _useWebProfileSplit(context);
    final shouldClear = !split ||
        (widget.embedInBottomBar && kIsWeb && bottomBarTabIndex != 4);
    if (!shouldClear) return;
    _shellResetScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shellResetScheduled = false;
      if (!mounted || _webShellDetail == null) return;
      final split2 = _useWebProfileSplit(context);
      final tab = widget.embedInBottomBar && kIsWeb
          ? context.read<BottomBarScreenViewModel>().selectedIndex
          : 4;
      if (!split2 || tab != 4) {
        setState(() => _webShellDetail = null);
      }
    });
  }

  void _handleProfileSettingTap(
    BuildContext context,
    ProfileScreenViewModel model,
    int index,
  ) {
    if (!_useWebProfileSplit(context)) {
      model.onTapFun(context, index);
      return;
    }
    switch (index) {
      case 0:
        setState(() => _webShellDetail = _WebProfileShellDetail.public);
        break;
      case 1:
        setState(() => _webShellDetail = _WebProfileShellDetail.private);
        break;
      case 3:
        setState(() => _webShellDetail = _WebProfileShellDetail.terms);
        break;
      case 4:
        setState(() => _webShellDetail = _WebProfileShellDetail.privacy);
        break;
      default:
        model.onTapFun(context, index);
    }
  }

  void _handleFollowersTap(
    BuildContext context,
    ProfileScreenViewModel model,
  ) {
    if (_useWebProfileSplit(context)) {
      setState(() => _webShellDetail = _WebProfileShellDetail.followers);
    } else {
      model.openFollowers(context);
    }
  }

  void _handleFollowingTap(
    BuildContext context,
    ProfileScreenViewModel model,
  ) {
    if (_useWebProfileSplit(context)) {
      setState(() => _webShellDetail = _WebProfileShellDetail.following);
    } else {
      model.openFollowing(context);
    }
  }

  Widget _buildWebShellDetailPane(
    BuildContext context,
    ProfileScreenViewModel model,
  ) {
    final detail = _webShellDetail;
    if (detail == null) return const SizedBox.shrink();
    final close = _closeWebShell;
    final followArgs = FollowConnectionsArgs(userId: ProfileService().profile?.id);

    switch (detail) {
      case _WebProfileShellDetail.public:
        return PublicProfileScreen(
          args: PublicProfileArgs(
            userId: ProfileService().profile?.id ?? '',
            displayName: model.fullName,
            forceRefreshProfile: true,
          ),
          onEmbeddedClose: close,
        );
      case _WebProfileShellDetail.private:
        return PrivateProfileScreen(onEmbeddedClose: close);
      case _WebProfileShellDetail.terms:
        return TermsOfServiceScreen(onEmbeddedClose: close);
      case _WebProfileShellDetail.privacy:
        return PrivacyPolicyScreen(onEmbeddedClose: close);
      case _WebProfileShellDetail.followers:
        return FollowersScreen(args: followArgs, onEmbeddedClose: close);
      case _WebProfileShellDetail.following:
        return FollowingScreen(args: followArgs, onEmbeddedClose: close);
    }
  }

  Widget _buildNotificationBell(BuildContext context) {
    final c = context.appColors;
    final unreadCount = context.select<NotificationService, int>(
      (service) => service.unreadNonDirectMessageCount,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SvgPicture.asset(AppAssets.notificationIcon),
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

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showAppDialog<bool>(
      context,
      title: AppText.logoutConfirmationTitle,
      message: AppText.logoutConfirmationMessage,
      actions: [
        AppDialogAction(
          label: AppText.cancel,
          onPressed: (dialogContext) => Navigator.pop(dialogContext, false),
        ),
        AppDialogAction(
          label: AppText.logout,
          isDestructive: true,
          onPressed: (dialogContext) => Navigator.pop(dialogContext, true),
        ),
      ],
    );

    if (shouldLogout != true || !context.mounted) return;

    final refreshToken = await AppPreferences.getRefreshToken();

    try {
      await FcmService.instance.deactivateForLogout();
    } catch (e) {
      debugPrint(
        '[ProfileScreen] FCM deactivate failed (continuing logout): $e',
      );
    }

    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        final response = await LogoutRepository().logout(
          request: LogoutRequestModel(refreshToken: refreshToken),
        );
        debugPrint('[ProfileScreen] Logout API success: ${response.message}');
      } else {
        debugPrint(
          '[ProfileScreen] Refresh token missing, skipping logout API and clearing local session only',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBar.show(e.toString(), backgroundColor: context.appColors.error);
      return;
    }

    await LoginScreenViewModel.logout(pushTokenAlreadyDeactivated: true);
    ListOfAllUserService().clear();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      RoutesName.LoginScreen,
      (route) => false,
    );
    AppSnackBar.show(AppText.logoutSuccess);
  }

  Future<void> _shareProfile(BuildContext context) async {
    final model = context.read<ProfileScreenViewModel>();
    final sportLine = model.sportsList.isNotEmpty
        ? model.sportsList
              .map((sport) => '${sport.name} (${sport.skill})')
              .join(', ')
        : '';

    final shareText = [
      'Check out my SportFinding profile!',
      model.fullName,
      if (model.bio.isNotEmpty) model.bio,
      if (model.location.isNotEmpty) 'Location: ${model.location}',
      if (sportLine.isNotEmpty) 'Sports: $sportLine',
      if (model.matchesPlayedLabel.isNotEmpty)
        'Matches: ${model.matchesPlayedLabel}',
    ].join('\n');

    await ShareSheetHelper.showShareSheet(
      context,
      title: model.fullName.isNotEmpty ? model.fullName : AppText.share,
      text: shareText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileScreenViewModel(),
      child: Consumer<ProfileScreenViewModel>(
        builder: (context, model, _) {
          final notificationService = context.watch<NotificationService>();
          final bottomBarTabIndex = widget.embedInBottomBar && kIsWeb
              ? context.select<BottomBarScreenViewModel, int>(
                  (vm) => vm.selectedIndex,
                )
              : 4;
          _maybeResetWebShell(context, bottomBarTabIndex);

          final useSplit = _useWebProfileSplit(context);
          final listBottomPad = widget.embedInBottomBar
              ? (kIsWeb && useSplit ? context.h(24) : context.h(100))
              : context.h(24);

          Widget mainScrollable() {
            return ListView(
              padding: context
                  .padSym(h: 20)
                  .copyWith(bottom: listBottomPad),
              children: [
                if (!widget.embedInBottomBar)
                  AppBarWidget(
                    onTapFirst: () => Navigator.pop(context),
                    leading: NormalText(titleText: AppText.sportFinding),
                    trailing: GestureDetector(
                      onTap: () async {
                        await notificationService.fetchNotifications();
                        if (!context.mounted) return;
                        Navigator.pushNamed(
                          context,
                          RoutesName.notificationsScreen,
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: _buildNotificationBell(context),
                    ),
                  ),
                NormalText(titleText: AppText.profile),
                SizedBox(height: context.h(16)),
                if (model.isLoading)
                  const _ProfileGreetingShimmer()
                else
                  UserGreetingWidget(
                    imageUrl: ProfileScreen._safeAvatarUrl(model.avatarUrl),
                    title: model.fullName,
                    locName: model.location,
                    subTitle: model.bio,
                    isShow: model.bio.isNotEmpty,
                  ),
                SizedBox(height: context.h(16)),
                ProfileDetailStatsRow(
                  followersCount: model.followersCount,
                  followingCount: model.followingCount,
                  ratingValue: model.ratingValue,
                  matchesPlayedValue: model.matchesPlayedLabel,
                  onFollowersTap: () => _handleFollowersTap(context, model),
                  onFollowingTap: () => _handleFollowingTap(context, model),
                ),
                SizedBox(height: context.h(16)),
                ListView.builder(
                  itemCount: model.profileData.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = model.profileData[index];
                    return Padding(
                      padding: context.padSym(v: 4),
                      child: CustomSettingCard(
                        icon: item['leading'],
                        title: item['title'],
                        subtitle: item['subtitle'],
                        trailingType: item['trailingType'],
                        switchValue: index == 2
                            ? model.notificationsEnabled
                            : item['switchValue'],
                        onSwitchChanged: index == 2
                            ? (val) async {
                                final message = await notificationService
                                    .updateNotificationPreference(val);
                                if (!context.mounted) return;
                                AppSnackBar.show(
                                  message != null && message.isNotEmpty
                                      ? message
                                      : AppText.notificationsUpdated,
                                );
                              }
                            : (val) {
                                model.toggleSwitch(index, val);
                              },
                        switchEnabled: index == 2
                            ? !notificationService.isUpdatingPreference
                            : true,
                        switchLoading: index == 2
                            ? notificationService.isUpdatingPreference
                            : false,
                        onTap: () =>
                            _handleProfileSettingTap(context, model, index),
                      ),
                    );
                  },
                ),
                if (!kIsWeb) ...[
                  SizedBox(height: context.h(8)),
                  CardWidget(
                    onTap: () => _handleLogout(context),
                    padding: context.padSym(h: 16, v: 14),
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: context.appColors.error,
                          size: context.w(24),
                        ),
                        SizedBox(width: context.w(8)),
                        Expanded(
                          child: NormalText(
                            titleText: AppText.logout,
                            titleStyle: context.appText.text14W600.copyWith(
                              color: context.appColors.error,
                            ),
                            subText: AppText.logoutSubtitle,
                            subStyle: context.appText.text12W400.copyWith(
                              color: context.appColors.greyDark,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: context.appColors.error,
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: context.h(16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomButton(
                        color: context.appColors.transparent,
                        outlined: true,
                        titleStyle: context.appText.text16Bold.copyWith(
                          color: AppColors.bluecolor,
                        ),
                        leading: SvgPicture.asset(AppAssets.edit),
                        borderColor: AppColors.bluecolor,
                        radius: BorderRadius.circular(context.radius(12)),
                        onTap: () {
                          final ps = ProfileService().profile;
                          String? sportUi;
                          String? skillUi;
                          if (ps != null && ps.sports.isNotEmpty) {
                            final raw = ps.sports.first;
                            if (raw is Map) {
                              final m = Map<String, dynamic>.from(raw);
                              sportUi = apiSportToUiDropdown(
                                m['sport']?.toString(),
                              );
                              skillUi = apiSkillToUiDropdown(
                                (m['skill_level'] ?? m['skill'])?.toString(),
                              );
                            }
                          }
                          Navigator.pushNamed(
                            context,
                            RoutesName.editProfileRoute,
                            arguments: EditProfileRouteArgs(
                              initialName: model.fullName,
                              initialBio: model.bio.isNotEmpty
                                  ? model.bio
                                  : null,
                              initialAvatarUrl:
                                  ProfileScreen._safeAvatarUrl(model.avatarUrl),
                              initialSport: sportUi,
                              initialSkill: skillUi,
                            ),
                          );
                        },
                        text: AppText.editProfile,
                      ),
                    ),
                    SizedBox(width: context.w(12)),
                    Expanded(
                      child: CustomButton(
                        color: context.appColors.transparent,
                        outlined: true,
                        titleStyle: context.appText.text16Bold.copyWith(
                          color: AppColors.bluecolor,
                        ),
                        leading: SvgPicture.asset(AppAssets.share),
                        borderColor: AppColors.bluecolor,
                        radius: BorderRadius.circular(context.radius(12)),
                        onTap: () => _shareProfile(context),
                        text: AppText.share,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          final frameChild = useSplit && _webShellDetail != null
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final leftW =
                        (constraints.maxWidth * 0.38).clamp(300.0, 440.0);
                    final dividerColor = context.appColors.greylight
                        .withValues(alpha: 0.2);
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: leftW,
                          child: mainScrollable(),
                        ),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: dividerColor,
                        ),
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: _buildWebShellDetailPane(context, model),
                          ),
                        ),
                      ],
                    );
                  },
                )
              : mainScrollable();

          return MainFrame(
            showDecorationLayer: !widget.embedInBottomBar,
            child: frameChild,
          );
        },
      ),
    );
  }
}

class _ProfileGreetingShimmer extends StatelessWidget {
  const _ProfileGreetingShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: const [
          ShimmerBox(width: 44, height: 44, shape: BoxShape.circle),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShimmerBox(width: 130, height: 14),
                SizedBox(height: 10),
                ShimmerBox(width: 110, height: 12),
                SizedBox(height: 10),
                ShimmerBox(width: 180, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
