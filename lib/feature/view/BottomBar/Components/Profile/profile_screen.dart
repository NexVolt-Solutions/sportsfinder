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
import 'package:sport_finding/core/Network/list_of_all_user_service.dart';
import 'package:sport_finding/feature/view/Auth/Login/login_viewmodel.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/profile_detail_widgets.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/profile_screen_view_model.dart';
import 'package:sport_finding/feature/webwidget/web_profile_content.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/custom_seeting_card.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/shimmer_loading.dart';
import 'package:sport_finding/feature/widget/user_greeting_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.embedInBottomBar = false});

  final bool embedInBottomBar;

  /// Returns a valid http URL or null — prevents passing placeholder
  /// strings like "default avatar url" to Image.network.
  static String? _safeAvatarUrl(String? raw) => normalizeImageUrl(raw);

  Widget _buildNotificationBell(BuildContext context) {
    final c = context.appColors;
    final unreadCount = context.select<NotificationService, int>(
      (service) => service.unreadCount,
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
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppText.logoutConfirmationTitle),
        content: const Text(AppText.logoutConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppText.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(AppText.logout),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;

    final refreshToken = await AppPreferences.getRefreshToken();

    try {
      await FcmService.instance.deactivateForLogout();
    } catch (e) {
      debugPrint('[ProfileScreen] FCM deactivate failed (continuing logout): $e');
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
          if (kIsWeb && embedInBottomBar) {
            return WebProfileContent(
              model: model,
              notificationsEnabled: model.notificationsEnabled,
              isUpdatingPreference: notificationService.isUpdatingPreference,
              safeAvatarUrl: _safeAvatarUrl(model.avatarUrl),
              onFollowersTap: () => model.openFollowers(context),
              onFollowingTap: () => model.openFollowing(context),
              onSwitchChanged: (val) async {
                final message = await notificationService
                    .updateNotificationPreference(val);
                if (!context.mounted) return;
                AppSnackBar.show(
                  message != null && message.isNotEmpty
                      ? message
                      : AppText.notificationsUpdated,
                );
              },
              onTapSetting: (index) => model.onTapFun(context, index),
              onPrimaryAction: () {
                final ps = ProfileService().profile;
                String? sportUi;
                String? skillUi;
                if (ps != null && ps.sports.isNotEmpty) {
                  final raw = ps.sports.first;
                  if (raw is Map) {
                    final m = Map<String, dynamic>.from(raw);
                    sportUi = apiSportToUiDropdown(m['sport']?.toString());
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
                    initialBio: model.bio.isNotEmpty ? model.bio : null,
                    initialAvatarUrl: _safeAvatarUrl(model.avatarUrl),
                    initialSport: sportUi,
                    initialSkill: skillUi,
                  ),
                );
              },
              onSecondaryAction: () => _shareProfile(context),
              primaryActionLabel: AppText.message,
            );
          }
          return MainFrame(
            showDecorationLayer: !embedInBottomBar,
            child: ListView(
              padding: context
                  .padSym(h: 20)
                  .copyWith(
                    bottom: embedInBottomBar ? context.h(100) : context.h(24),
                  ),
              children: [
                if (!embedInBottomBar)
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
                    imageUrl: _safeAvatarUrl(model.avatarUrl),
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
                  onFollowersTap: () => model.openFollowers(context),
                  onFollowingTap: () => model.openFollowing(context),
                ),
                SizedBox(height: context.h(16)),

                ListView.builder(
                  itemCount: model.profileData.length,
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = model.profileData[index];
                    return Padding(
                      padding: context.padSym(v: 8),
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
                        onTap: () => model.onTapFun(context, index),
                      ),
                    );
                  },
                ),
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
                // NormalText(titleText: AppText.mySports),
                // ListView.builder(
                //   itemCount: model.sportsList.length,
                //   shrinkWrap: true,
                //   physics: const NeverScrollableScrollPhysics(),
                //   itemBuilder: (context, index) {
                //     final sport = model.sportsList[index];
                //     return ProfilePrivateSportRow(
                //       sportName: sport.name,
                //       skillLabel: sport.skill,
                //     );
                //   },
                // ),
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
                              initialAvatarUrl: _safeAvatarUrl(model.avatarUrl),
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
            ),
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
