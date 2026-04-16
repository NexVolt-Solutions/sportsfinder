import 'package:flutter/material.dart';
import 'package:sport_finding/Data/model/my_profile_model.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/Data/model/my_sport.dart';
import 'package:sport_finding/Data/model/public_profile_args.dart';

class PublicProfileViewModel extends ChangeNotifier {
  late final VoidCallback _listener;
  final PublicProfileArgs? _args;

  PublicProfileViewModel({PublicProfileArgs? args}) : _args = args {
    // ✅ Store listener reference so we can remove it properly
    _listener = () => notifyListeners();
    // ✅ Forward ProfileService rebuilds into this ViewModel
    ProfileService().addListener(_listener);
    // ✅ Fetch — skips if already loaded by HomeScreen
    ProfileService().fetchMyProfile();
  }

  @override
  void dispose() {
    ProfileService().removeListener(_listener);
    super.dispose();
  }

  UserProfileModel? profile;
  bool isLoading = false;
  String? errorMessage;

  // --- getters ---
  String get id => profile?.id ?? 'default id';
  String get fullName => profile?.fullName ?? 'default name';
  String get email => profile?.email ?? 'default email';
  String get bio => profile?.bio ?? 'default bio';
  String get location => profile?.location ?? 'default location';
  String get avatarUrl => profile?.avatarUrl ?? 'default avatar url';
  bool get hasProfile => profile != null;
  bool get isAdmin => profile?.isAdmin == true;
  String get status => profile?.status ?? 'default status';
  List<dynamic> get sports => profile?.sports ?? [];
  int get totalReviews => profile?.totalReviews ?? 0;
  List<dynamic> get reviews => profile?.reviews ?? [];
  static const String kDemoAvatarUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400';

  String get displayName {
    final n = _args?.displayName.trim();
    if (n == null || n.isEmpty) return AppText.alexJohnson;
    return n;
  }

  // String get locationLabel => AppText.losAngelesCa;
  // String get bio => AppText.passionateAthleteBio;
  // String get avatarUrl => kDemoAvatarUrl;

  int get followersCount => 78;
  int get followingCount => 78;
  String get ratingValue => '4.5';

  List<MySport> get publicSports => [
    MySport(name: AppText.basketball, skill: AppText.intermediate),
    MySport(name: AppText.football, skill: AppText.advanced),
    MySport(name: AppText.tennis, skill: AppText.beginner),
  ];

  String get reviewAuthor => AppText.davidGam;
  String get reviewDate => AppText.oneDayAgo;
  String get reviewBody => AppText.hadAGreatMatchReview;
  String get reviewInitial {
    if (_args == null) return 'D';
    final n = displayName;
    if (n.isEmpty) return '?';
    return n[0].toUpperCase();
  }

  void openFollowers(BuildContext context) {
    Navigator.pushNamed(context, RoutesName.followersScreen);
  }

  void openFollowing(BuildContext context) {
    Navigator.pushNamed(context, RoutesName.followingScreen);
  }

  void onMessageTap(BuildContext context) {
    Navigator.pushNamed(context, RoutesName.chatScreen);
  }

  void onFollowTap(BuildContext context) {}

  void onRateTap(BuildContext context) {}
}
