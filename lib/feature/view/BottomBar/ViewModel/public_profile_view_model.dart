import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/Data/model/Review/create_review_model.dart';
import 'package:sport_finding/Data/model/chat_route_args.dart';
import 'package:sport_finding/Data/Repositories/FollowUser/follow_user_repo.dart';
import 'package:sport_finding/Data/Repositories/Review/review_repository.dart';
import 'package:sport_finding/Data/model/follow_connections_args.dart';
import 'package:sport_finding/Data/model/my_profile_model.dart';
import 'package:sport_finding/Data/model/my_sport.dart';
import 'package:sport_finding/Data/model/public_profile_args.dart';
import 'package:sport_finding/Data/Repositories/my_profile_repository.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/api_error_message.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';

class PublicProfileViewModel extends ChangeNotifier {
  PublicProfileViewModel({PublicProfileArgs? args}) : _args = args {
    _listener = () {
      Future.microtask(_safeNotifyListeners);
    };
    ProfileService().addListener(_listener);
    Future.microtask(_load);
  }

  bool _disposed = false;

  void _safeNotifyListeners() {
    if (_disposed) return;
    notifyListeners();
  }

  final PublicProfileArgs? _args;
  final MyProfileRepository _repo = MyProfileRepository(
    apiService: ApiService(),
  );
  final ReviewRepository _reviewRepository = ReviewRepository();
  final FollowUserRepo _followUserRepo = FollowUserRepo();

  late final VoidCallback _listener;

  UserProfileModel? _otherProfile;
  bool _fetchOtherLoading = false;
  String? _fetchOtherError;
  bool _submitReviewLoading = false;
  String? _submitReviewError;
  bool _followLoading = false;
  String? _followError;
  bool? _isFollowingOverride;
  int? _followersCountOverride;
  bool? _canRateOverride;

  /// True when opening from settings (no args) or empty [userId], or when the
  /// selected user is the logged-in account.
  bool get _viewingSelf {
    if (_args == null) return true;
    final uid = _args.userId.trim();
    if (uid.isEmpty) return true;
    final myId = ProfileService().profile?.id;
    if (myId == null || myId.isEmpty) return false;
    return uid == myId;
  }

  UserProfileModel? get _active {
    if (_viewingSelf) return ProfileService().profile;
    return _otherProfile;
  }

  bool get showSpinner {
    if (_viewingSelf) {
      final ps = ProfileService();
      return ps.isLoading && ps.profile == null;
    }
    return _fetchOtherLoading && _otherProfile == null;
  }

  bool get showError {
    if (_viewingSelf) {
      final ps = ProfileService();
      return !ps.isLoading && ps.profile == null && ps.errorMessage != null;
    }
    return !_fetchOtherLoading &&
        _otherProfile == null &&
        _fetchOtherError != null;
  }

  String get displayError {
    if (_viewingSelf) {
      return ProfileService().errorMessage ?? '';
    }
    return _fetchOtherError ?? '';
  }

  bool get isSubmittingReview => _submitReviewLoading;
  String? get submitReviewError => _submitReviewError;
  bool get isFollowLoading => _followLoading;
  String? get followError => _followError;
  String get selectedUserId => _args?.userId.trim() ?? '';
  String get initialMatchId => _args?.initialMatchId?.trim() ?? '';

  /// Hide follow / message / rate when viewing your own public profile.
  bool get isOwnProfile =>
      _viewingSelf || (_active?.actions.isOwnProfile ?? false);
  bool get canRateProfile =>
      !isOwnProfile && (_canRateOverride ?? (_active?.actions.canRate ?? true));

  Future<void> _load() async {
    if (_viewingSelf) {
      final refresh = _args?.forceRefreshProfile ?? false;
      try {
        await ProfileService().fetchMyProfile(forceRefresh: refresh);
      } catch (_) {}
      _safeNotifyListeners();
      return;
    }

    _fetchOtherLoading = true;
    _fetchOtherError = null;
    _safeNotifyListeners();

    try {
      final raw = await _repo.getUserById(_args!.userId.trim());
      if (!_disposed) {
        if (raw is Map) {
          _otherProfile = UserProfileModel.fromJson(
            Map<String, dynamic>.from(raw),
          );
          _fetchOtherError = null;
        } else {
          throw Exception('Invalid profile response');
        }
      }
    } catch (e) {
      if (!_disposed) {
        _fetchOtherError = e.toString();
        _otherProfile = null;
      }
    } finally {
      if (!_disposed) {
        _fetchOtherLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    ProfileService().removeListener(_listener);
    super.dispose();
  }

  String get fullName {
    final p = _active;
    if (p != null && p.fullName.trim().isNotEmpty) return p.fullName.trim();
    final a = _args?.displayName.trim();
    if (a != null && a.isNotEmpty) return a;
    if (showSpinner || showError) return '';
    return AppText.profilePlaceholderName;
  }

  String get bio {
    final b = _active?.bio?.trim() ?? '';
    if (b.isNotEmpty) return b;
    if (showSpinner || showError) return '';
    return AppText.profilePlaceholderBio;
  }

  String get location {
    final l = _active?.location?.trim() ?? '';
    if (l.isNotEmpty) return l;
    if (showSpinner || showError) return '';
    return AppText.profilePlaceholderLocation;
  }

  String get avatarUrl => normalizeImageUrl(_active?.avatarUrl)?.trim() ?? '';

  int get followersCount =>
      _followersCountOverride ?? (_active?.stats.followers ?? 0);
  int get followingCount => _active?.stats.following ?? 0;
  bool get isFollowing =>
      _isFollowingOverride ?? (_active?.actions.isFollowing ?? false);

  String get ratingValue {
    final r = _active?.stats.rating;
    if (r == null) return '—';
    return r.toStringAsFixed(1);
  }

  String get matchesPlayedValue => '${_active?.stats.matches ?? 0}';

  List<MySport> get publicSports {
    final raw = _active?.sports ?? [];
    final out = <MySport>[];
    for (final e in raw) {
      if (e is Map) {
        final m = Map<String, dynamic>.from(e);
        final name = '${m['name'] ?? m['sport'] ?? ''}'.trim();
        if (name.isEmpty) continue;
        final skill = '${m['skill'] ?? m['skill_level'] ?? ''}'.trim();
        out.add(MySport(name: name, skill: skill.isEmpty ? '—' : skill));
      }
    }
    return out;
  }

  /// One placeholder row when the API returns no sports (after load).
  List<MySport> get publicSportsForDisplay {
    if (showSpinner || showError) return publicSports;
    if (publicSports.isNotEmpty) return publicSports;
    return [MySport(name: AppText.profilePlaceholderSport, skill: '')];
  }

  Map<String, dynamic>? get _firstReviewMap {
    final list = _active?.reviews;
    if (list == null || list.isEmpty) return null;
    final first = list.first;
    if (first is Map) return Map<String, dynamic>.from(first);
    return null;
  }

  List<Map<String, String>> get parsedReviews {
    final list = _active?.reviews;
    if (list == null || list.isEmpty) return const <Map<String, String>>[];

    final out = <Map<String, String>>[];
    for (final item in list) {
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);
      final authorRaw =
          m['author_name'] ??
          m['reviewer_name'] ??
          m['reviewer'] ??
          m['author'] ??
          m['user'];
      final author = authorRaw is Map
          ? '${authorRaw['full_name'] ?? authorRaw['name'] ?? ''}'.trim()
          : '${authorRaw ?? ''}'.trim();

      final body = '${m['body'] ?? m['comment'] ?? m['text'] ?? ''}'.trim();
      final rawDate = m['created_at'] ?? m['date'] ?? m['reviewed_at'];
      String date = '';
      if (rawDate != null) {
        final parsed = DateTime.tryParse(rawDate.toString());
        date = parsed == null
            ? rawDate.toString()
            : '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
      }

      if (author.isEmpty && body.isEmpty) continue;
      out.add(<String, String>{
        'author': author.isEmpty ? '—' : author,
        'body': body.isEmpty ? AppText.profilePlaceholderReview : body,
        'date': date,
        'initial': author.isEmpty ? '?' : author[0].toUpperCase(),
      });
    }

    return out;
  }

  bool get hasReviews {
    final total = _active?.totalReviews ?? 0;
    if (total > 0) return true;
    final list = _active?.reviews;
    if (list == null || list.isEmpty) return false;
    for (final item in list) {
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);
      final authorRaw =
          m['author_name'] ??
          m['reviewer_name'] ??
          m['reviewer'] ??
          m['author'] ??
          m['user'];
      final author = authorRaw is Map
          ? '${authorRaw['full_name'] ?? authorRaw['name'] ?? ''}'.trim()
          : '${authorRaw ?? ''}'.trim();
      final body = '${m['body'] ?? m['comment'] ?? m['text'] ?? ''}'.trim();
      if (author.isNotEmpty || body.isNotEmpty) return true;
    }
    return false;
  }

  String get reviewAuthor {
    final m = _firstReviewMap;
    if (m == null) return '';
    final name =
        m['author_name'] ??
        m['reviewer_name'] ??
        m['reviewer'] ??
        m['author'] ??
        m['user'];
    if (name is Map) return '${name['full_name'] ?? name['name'] ?? ''}';
    return name?.toString() ?? '';
  }

  String get reviewAuthorForDisplay {
    final s = reviewAuthor.trim();
    if (s.isNotEmpty) return s;
    if (showSpinner || showError) return '';
    return '—';
  }

  String get reviewDate {
    final m = _firstReviewMap;
    if (m == null) return '';
    final d = m['created_at'] ?? m['date'] ?? m['reviewed_at'];
    if (d == null) return '';
    final parsed = DateTime.tryParse(d.toString());
    if (parsed == null) return d.toString();
    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }

  String get reviewDateForDisplay {
    final s = reviewDate.trim();
    if (s.isNotEmpty) return s;
    if (showSpinner || showError) return '';
    return '';
  }

  String get reviewBody {
    final m = _firstReviewMap;
    if (m == null) return '';
    return '${m['body'] ?? m['comment'] ?? m['text'] ?? ''}'.trim();
  }

  String get reviewBodyForDisplay {
    final s = reviewBody.trim();
    if (s.isNotEmpty) return s;
    if (showSpinner || showError) return '';
    return AppText.profilePlaceholderReview;
  }

  String get reviewInitial {
    final author = reviewAuthorForDisplay.trim();
    if (author.isEmpty || author == '—') return '?';
    return author[0].toUpperCase();
  }

  String get displayName => fullName;

  void openFollowers(BuildContext context) {
    Navigator.pushNamed(
      context,
      RoutesName.followersScreen,
      arguments: FollowConnectionsArgs(userId: selectedUserId),
    );
  }

  void openFollowing(BuildContext context) {
    Navigator.pushNamed(
      context,
      RoutesName.followingScreen,
      arguments: FollowConnectionsArgs(userId: selectedUserId),
    );
  }

  void onMessageTap(BuildContext context) {
    if (selectedUserId.isEmpty) {
      AppSnackBar.show(AppText.invalidUserProfile);
      return;
    }

    final matchId = initialMatchId.trim();
    Navigator.pushNamed(
      context,
      RoutesName.chatScreen,
      arguments: ChatRouteArgs(
        contactName: fullName.isNotEmpty ? fullName : 'Player Chat',
        matchId: matchId.isEmpty ? null : matchId,
        targetUserId: selectedUserId,
        isOnline: true,
      ),
    );
  }

  Future<void> onFollowTap(BuildContext context) async {
    if (isOwnProfile || selectedUserId.isEmpty || _followLoading) {
      log(
        'ℹ️ [PublicProfileVM] Follow tap ignored '
        '(isOwnProfile: $isOwnProfile, selectedUserId: $selectedUserId, '
        'isLoading: $_followLoading, isFollowing: $isFollowing)',
      );
      return;
    }
    if (isFollowing) {
      openFollowers(context);
      return;
    }

    _followLoading = true;
    _followError = null;
    _safeNotifyListeners();

    try {
      log('🚀 [PublicProfileVM] Follow API hit for userId: $selectedUserId');
      await _followUserRepo.followUser(userId: selectedUserId);
      if (_disposed) return;
      log('✅ [PublicProfileVM] Follow API success for userId: $selectedUserId');
      _isFollowingOverride = true;
      _followersCountOverride = followersCount + 1;
      _followError = null;
      _safeNotifyListeners();

      if (!context.mounted) return;
      AppSnackBar.show('User followed successfully');
      openFollowers(context);
    } catch (e) {
      if (_disposed) return;
      log('❌ [PublicProfileVM] Follow API failed for userId: $selectedUserId');
      log('📍 [PublicProfileVM] Follow error: $e');
      _followError = e.toString();
      _safeNotifyListeners();

      if (!context.mounted) return;
      AppSnackBar.show(_followError ?? 'Failed to follow user');
    } finally {
      if (!_disposed) {
        _followLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<bool> submitReview({
    required int rating,
    required String comment,
  }) async {
    log(
      '[PublicProfileVM] submitReview tapped for userId=$selectedUserId, '
      'rating=$rating',
    );
    if (_submitReviewLoading) {
      return false;
    }
    if (isOwnProfile) {
      _submitReviewError = AppText.cannotRateOwnProfile;
      _safeNotifyListeners();
      return false;
    }
    if (!canRateProfile) {
      _submitReviewError = 'You have already submitted a profile review for this user.';
      _safeNotifyListeners();
      return false;
    }
    if (selectedUserId.isEmpty) {
      _submitReviewError = AppText.invalidUserProfile;
      _safeNotifyListeners();
      return false;
    }
    _submitReviewLoading = true;
    _submitReviewError = null;
    _safeNotifyListeners();

    try {
      await _reviewRepository.createReview(
        userId: selectedUserId,
        request: CreateReviewRequestModel(
          rating: rating,
          comment: comment.trim(),
        ),
      );
      if (_disposed) return false;
      log(
        '[PublicProfileVM] submitReview success for userId=$selectedUserId',
      );

      final raw = await _repo.getUserById(selectedUserId);
      if (_disposed) return false;
      if (raw is Map) {
        _otherProfile = UserProfileModel.fromJson(
          Map<String, dynamic>.from(raw),
        );
      }

      _submitReviewLoading = false;
      _submitReviewError = null;
      _safeNotifyListeners();
      return true;
    } catch (e) {
      if (_disposed) return false;
      log(
        '[PublicProfileVM] submitReview failed for userId=$selectedUserId: $e',
      );
      _submitReviewLoading = false;
      _submitReviewError = messageFromApiException(e);
      if ((_submitReviewError ?? '').toLowerCase().contains(
        'already submitted a profile review',
      )) {
        _canRateOverride = false;
      }
      _safeNotifyListeners();
      return false;
    }
  }
}
