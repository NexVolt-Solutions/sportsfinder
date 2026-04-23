import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/Data/model/follow_connections_args.dart';
import 'package:sport_finding/Data/model/public_profile_args.dart';
import 'package:sport_finding/Data/model/my_sport.dart'; // Added VoidCallback import

class ProfileScreenViewModel extends ChangeNotifier {
  late final VoidCallback _listener;

  ProfileScreenViewModel() {
    // ✅ Store listener reference so we can remove it properly
    _listener = () => notifyListeners();
    // ✅ Forward ProfileService rebuilds into this ViewModel
    ProfileService().addListener(_listener);
    // Defer so [ProfileService.notifyListeners] does not run during first profile build
    // (avoids "setState during build" on [AllUpcommingMatchesViewModel]).
    Future<void>.microtask(() => ProfileService().fetchMyProfile());
  }

  @override
  void dispose() {
    ProfileService().removeListener(_listener);
    super.dispose();
  }

  // ✅ All profile data comes from ProfileService singleton
  ProfileService get _ps => ProfileService();

  String get fullName => _ps.fullName;
  String get avatarUrl => _ps.avatarUrl;
  String get email => _ps.email;
  String get bio => _ps.bio;
  String get location => _ps.location;
  bool get isLoading => _ps.isLoading;
  bool get showBioOnProfile => true;

  int get followersCount => _ps.profile?.stats.followers ?? 0;
  int get followingCount => _ps.profile?.stats.following ?? 0;
  int get matchesPlayedCount => _ps.profile?.stats.matches ?? 0;

  String get followersCountLabel => '$followersCount';
  String get followingCountLabel => '$followingCount';
  String get matchesPlayedLabel => '$matchesPlayedCount';
  bool get notificationsEnabled => _ps.notificationsEnabled;

  // --- unchanged below ---
  int selectedSportIndex = -1;

  List<Map<String, dynamic>> profileData = [
    {
      'leading': AppAssets.eyeIcon,
      'title': AppText.publicProfile,
      'subtitle': AppText.seeWhatYourProfileLooksLikeToOthers,
      'trailingType': 'arrow',
      'switchValue': false,
    },
    {
      'leading': AppAssets.eyeIcon,
      'title': AppText.privateProfile,
      'subtitle': AppText.seeWhatYourProfileLooksLikeToOthers,
      'trailingType': 'arrow',
      'switchValue': false,
    },
    {
      'leading': AppAssets.notificationIcon,
      'title': AppText.notification,
      'subtitle': AppText.pushNotificationEnabled,
      'trailingType': 'switch',
      'switchValue': false,
    },
    {
      'leading': AppAssets.termIcon,
      'title': AppText.termsOfService,
      'subtitle': AppText.readOurTermsOfServices,
      'trailingType': 'arrow',
      'switchValue': false,
    },
    {
      'leading': AppAssets.privacyIcon,
      'title': AppText.privacyPolicy,
      'subtitle': AppText.readOurTermsOfPrivacyPolicy,
      'trailingType': 'arrow',
      'switchValue': false,
    },
  ];

  List<MySport> sportsList = [
    MySport(name: AppText.football, skill: AppText.beginner),
    MySport(name: AppText.basketball, skill: AppText.intermediate),
    MySport(name: AppText.tennis, skill: AppText.advanced),
    MySport(name: AppText.volleyball, skill: AppText.beginner),
  ];

  void toggleSwitch(int index, bool value) {
    if (index == 2) {
      profileData[index]['switchValue'] = notificationsEnabled;
    } else {
      profileData[index]['switchValue'] = value;
    }
    notifyListeners();
  }

  void openFollowers(BuildContext context) => Navigator.pushNamed(
    context,
    RoutesName.followersScreen,
    arguments: FollowConnectionsArgs(userId: _ps.profile?.id),
  );

  void openFollowing(BuildContext context) => Navigator.pushNamed(
    context,
    RoutesName.followingScreen,
    arguments: FollowConnectionsArgs(userId: _ps.profile?.id),
  );

  void openNotifications(BuildContext context) =>
      Navigator.pushNamed(context, RoutesName.notificationsScreen);

  void onTapFun(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(
          context,
          RoutesName.publicProfileScreen,
          arguments: PublicProfileArgs(
            userId: _ps.profile?.id ?? '',
            displayName: _ps.fullName,
            forceRefreshProfile: true,
          ),
        );
        break;
      case 1:
        Navigator.pushNamed(context, RoutesName.privateProfileScreen);
        break;
      case 3:
        Navigator.pushNamed(context, RoutesName.termsOfServiceScreen);
        break;
      case 4:
        Navigator.pushNamed(context, RoutesName.privacyPolicyScreen);
        break;
      default:
        break;
    }
  }
}
