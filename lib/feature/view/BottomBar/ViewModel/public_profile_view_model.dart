import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/Data/model/CreateReviewRequest/create_review_request_model.dart';
import 'package:sport_finding/Data/model/my_profile_model.dart';
import 'package:sport_finding/Data/model/my_sport.dart';
import 'package:sport_finding/Data/model/public_profile_args.dart';
import 'package:sport_finding/Data/Repositories/CreateReviewRequest/create_review_repo.dart';
import 'package:sport_finding/Data/Repositories/my_profile_repository.dart';
import 'package:sport_finding/core/Network/api_service.dart';
import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';

class PublicProfileViewModel extends ChangeNotifier {
  PublicProfileViewModel({PublicProfileArgs? args}) : _args = args {
    _listener = () {
      Future.microtask(notifyListeners);
    };
    ProfileService().addListener(_listener);
    Future.microtask(_load);
  }

  final PublicProfileArgs? _args;
  final MyProfileRepository _repo = MyProfileRepository(
    apiService: ApiService(),
  );
  final CreateReviewRepo _createReviewRepo = CreateReviewRepo();

  late final VoidCallback _listener;

  UserProfileModel? _otherProfile;
  bool _fetchOtherLoading = false;
  String? _fetchOtherError;
  bool _submitReviewLoading = false;
  String? _submitReviewError;

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
  String get selectedUserId => _args?.userId.trim() ?? '';
  String get initialMatchId => _args?.initialMatchId?.trim() ?? '';

  /// Hide follow / message / rate when viewing your own public profile.
  bool get isOwnProfile =>
      _viewingSelf || (_active?.actions.isOwnProfile ?? false);

  Future<void> _load() async {
    if (_viewingSelf) {
      final refresh =
          _args?.forceRefreshProfile ?? false;
      try {
        await ProfileService().fetchMyProfile(forceRefresh: refresh);
      } catch (_) {}
      notifyListeners();
      return;
    }

    _fetchOtherLoading = true;
    _fetchOtherError = null;
    notifyListeners();

    try {
      final raw = await _repo.getUserById(_args!.userId.trim());
      if (raw is Map) {
        _otherProfile = UserProfileModel.fromJson(
          Map<String, dynamic>.from(raw),
        );
        _fetchOtherError = null;
      } else {
        throw Exception('Invalid profile response');
      }
    } catch (e) {
      _fetchOtherError = e.toString();
      _otherProfile = null;
    } finally {
      _fetchOtherLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
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

  String get avatarUrl => _active?.avatarUrl?.trim() ?? '';

  int get followersCount => _active?.stats.followers ?? 0;
  int get followingCount => _active?.stats.following ?? 0;

  String get ratingValue {
    final r = _active?.stats.rating;
    if (r == null) return '—';
    return r.toStringAsFixed(1);
  }

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
    return [
      MySport(name: AppText.profilePlaceholderSport, skill: ''),
    ];
  }

  Map<String, dynamic>? get _firstReviewMap {
    final list = _active?.reviews;
    if (list == null || list.isEmpty) return null;
    final first = list.first;
    if (first is Map) return Map<String, dynamic>.from(first);
    return null;
  }

  String get reviewAuthor {
    final m = _firstReviewMap;
    if (m == null) return '';
    final name =
        m['author_name'] ?? m['reviewer_name'] ?? m['author'] ?? m['user'];
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
    Navigator.pushNamed(context, RoutesName.followersScreen);
  }

  void openFollowing(BuildContext context) {
    Navigator.pushNamed(context, RoutesName.followingScreen);
  }

  void onMessageTap(BuildContext context) {
    Navigator.pushNamed(context, RoutesName.chatScreen);
  }

  void onFollowTap(BuildContext context) {}

  Future<bool> submitReview({
    required String matchId,
    required int rating,
    required String comment,
  }) async {
    if (isOwnProfile) {
      _submitReviewError = AppText.cannotRateOwnProfile;
      notifyListeners();
      return false;
    }
    if (selectedUserId.isEmpty) {
      _submitReviewError = AppText.invalidUserProfile;
      notifyListeners();
      return false;
    }

    _submitReviewLoading = true;
    _submitReviewError = null;
    notifyListeners();

    try {
      await _createReviewRepo.createReview(
        userId: selectedUserId,
        data: CreateReviewRequestModel(
          matchId: matchId.trim(),
          rating: rating,
          comment: comment.trim(),
        ),
      );

      final raw = await _repo.getUserById(selectedUserId);
      if (raw is Map) {
        _otherProfile = UserProfileModel.fromJson(Map<String, dynamic>.from(raw));
      }

      _submitReviewLoading = false;
      _submitReviewError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _submitReviewLoading = false;
      _submitReviewError = e.toString();
      notifyListeners();
      return false;
    }
  }
}
