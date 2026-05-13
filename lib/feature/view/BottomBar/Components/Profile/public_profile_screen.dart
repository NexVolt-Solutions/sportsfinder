import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/Data/model/public_profile_args.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/profile_detail_widgets.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/public_profile_pixel_widgets.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/public_profile_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/shimmer_loading.dart';

class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({super.key, this.args, this.onEmbeddedClose});

  final PublicProfileArgs? args;

  /// Web profile split shell: back closes the pane instead of [Navigator.pop].
  final VoidCallback? onEmbeddedClose;

  void _popOrClose(BuildContext context) {
    final c = onEmbeddedClose;
    if (c != null) {
      c();
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildPixelProfile(
    BuildContext context,
    PublicProfileViewModel model,
  ) {
    final sports = <({String name, String skill, String category})>[
      for (final s in model.publicSportsForDisplay)
        (name: s.name, skill: s.skill, category: s.category),
    ];
    final reviews =
        <
          ({
            String author,
            String date,
            String body,
            String initial,
            int ratingStars,
          })
        >[
          for (final r in model.parsedReviews)
            (
              author: r['author'] ?? '—',
              date: r['date'] ?? '',
              body: r['body'] ?? AppText.profilePlaceholderReview,
              initial: r['initial'] ?? '?',
              ratingStars: int.tryParse(r['rating'] ?? '') ?? 0,
            ),
        ];
    return PublicProfilePixelScaffold(
      onBack: () => _popOrClose(context),
      displayName: model.fullName,
      location: model.location,
      bio: model.bio,
      avatarUrl: model.avatarUrl,
      followers: '${model.followersCount}',
      following: '${model.followingCount}',
      rating: model.ratingValue,
      matches: model.matchesPlayedValue,
      sports: sports,
      reviews: reviews,
      isOwnProfile: model.isOwnProfile,
      onMessage: model.isOwnProfile ? null : () => model.onMessageTap(context),
      onFollow: model.isOwnProfile ? null : () => model.onFollowTap(context),
      isFollowing: model.isFollowing,
      isFollowLoading: model.isFollowLoading,
      onFollowersTap: model.isOwnProfile
          ? () => model.openFollowers(context)
          : null,
      onFollowingTap: model.isOwnProfile
          ? () => model.openFollowing(context)
          : null,
      onRatingTap: model.isOwnProfile
          ? () => _showRateSheet(context, model)
          : !model.canRateProfile
          ? null
          : () => _showRateSheet(context, model),
      onMatchesTap: null,
      onRatePlayer: model.isOwnProfile || model.canRateProfile
          ? () => _showRateSheet(context, model)
          : null,
      showRateButton: model.isOwnProfile || model.canRateProfile,
      onAllSportsTap: null,
    );
  }

  void _showRateSheet(BuildContext context, PublicProfileViewModel model) {
    final c = context.appColors;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius(14)),
        ),
      ),
      builder: (sheetContext) => _RatePlayerSheet(model: model),
    );
  }

  /// Same structure as [PrivateProfileScreen] (mobile / native). For other
  /// users only, Message + Follow are inserted after stats (web pixel UI
  /// still handles Rate separately).
  Widget _buildMobileListProfile(
    BuildContext context,
    PublicProfileViewModel model,
  ) {
    final c = context.appColors;
    final t = context.appText;

    return MainFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: context.padSym(h: 20),
            child: AppBarWidget(
              title: AppText.publicProfile,
              onLeadingTap: () => _popOrClose(context),
            ),
          ),
          Expanded(
            child: model.showSpinner
                ? const _MobilePublicProfileShimmer()
                : model.showError
                ? Padding(
                    padding: context.padSym(h: 20),
                    child: Center(
                      child: Text(
                        model.displayError,
                        textAlign: TextAlign.center,
                        style: t.text14W400.copyWith(color: c.greyDark),
                      ),
                    ),
                  )
                : ListView(
                    padding: context
                        .padSym(h: 20)
                        .copyWith(bottom: context.h(32)),
                    children: [
                      ProfileDetailHeader(
                        displayName: model.fullName,
                        locationLabel: model.location,
                        bio: model.bio,
                        avatarUrl: model.avatarUrl,
                        showTrophyBadge: true,
                        nameStyle: t.style(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: c.onSurface,
                          height: 1.2,
                        ),
                        bioStyle: t.text14W400.copyWith(
                          color: c.greyDark,
                          height: 1.45,
                        ),
                        locationStyle: t.text14W500.copyWith(
                          color: c.greylight,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: context.h(16)),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 3,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  context.radius(32),
                                ),
                              ),
                              child: CustomButton(
                                padding: context.paddingSymmetric(vertical: 4),
                                text: AppText.message,
                                outlined: true,
                                borderColor: c.transparent,
                                titleStyle: t.text16W500.copyWith(
                                  color: c.onSurface,
                                ),
                                radius: BorderRadius.circular(
                                  context.radius(32),
                                ),
                                onTap: () {
                                  if (!model.isOwnProfile) {
                                    model.onMessageTap(context);
                                  } else {
                                    AppSnackBar.show(
                                      "You cannot message yourself",
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: context.w(12)),
                          Expanded(
                            child: CustomButton(
                              text: model.isFollowing
                                  ? AppText.unfollow
                                  : AppText.follow,
                              outlined: model.isFollowing,
                              borderColor: c.primary,
                              titleStyle: t.text16Bold.copyWith(
                                color: model.isFollowing
                                    ? c.primary
                                    : c.onPrimary,
                              ),
                              radius: BorderRadius.circular(context.radius(32)),
                              isLoading: model.isFollowLoading,
                              onTap: () {
                                if (!model.isOwnProfile) {
                                  model.onFollowTap(context);
                                } else {
                                  AppSnackBar.show(
                                    "You cannot follow yourself",
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.h(8)),
                      CustomButton(
                        text: AppText.ratePlayer,
                        onTap: () {
                          _showRateSheet(context, model);
                        },
                        radius: BorderRadius.circular(context.radius(32)),
                        outlined: true,
                        titleStyle: t.text16Bold.copyWith(color: c.primary),
                        borderColor: c.primary,
                      ),
                      SizedBox(height: context.h(16)),

                      ProfileDetailStatsRow(
                        followersCount: model.followersCount,
                        followingCount: model.followingCount,
                        ratingValue: model.ratingValue,
                        matchesPlayedValue: model.matchesPlayedValue,
                        onFollowersTap: model.isOwnProfile
                            ? () => model.openFollowers(context)
                            : null,
                        onFollowingTap: model.isOwnProfile
                            ? () => model.openFollowing(context)
                            : null,
                      ),

                      SizedBox(height: context.h(16)),
                      NormalText(
                        titleText: AppText.mySports,
                        titleStyle: t.text16Bold.copyWith(color: c.greyDark),
                      ),
                      ...model.publicSportsForDisplay.map(
                        (s) => ProfilePrivateSportRow(
                          sportName: s.name,
                          skillLabel: s.skill,
                          categoryLabel: s.category,
                        ),
                      ),
                      if (model.hasReviews) ...[
                        SizedBox(height: context.h(8)),
                        NormalText(
                          titleText: AppText.reviews,
                          titleStyle: t.text16Bold.copyWith(color: c.greyDark),
                        ),
                        ...model.parsedReviews.map(
                          (review) => Padding(
                            padding: EdgeInsets.only(bottom: context.h(10)),
                            child: ProfileDetailReviewCard(
                              reviewAuthor: review['author'] ?? '—',
                              reviewDate: review['date'] ?? '',
                              reviewBody:
                                  review['body'] ??
                                  AppText.profilePlaceholderReview,
                              reviewInitial: review['initial'] ?? '?',
                              reviewRatingStars:
                                  int.tryParse(review['rating'] ?? '') ?? 0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PublicProfileViewModel(args: args),
      child: Scaffold(
        backgroundColor: onEmbeddedClose != null
            ? Colors.transparent
            : Theme.of(context).scaffoldBackgroundColor,
        body: Consumer<PublicProfileViewModel>(
          builder: (context, model, _) {
            final c = context.appColors;
            final t = context.appText;

            if (!kIsWeb) {
              return _buildMobileListProfile(context, model);
            }

            if (model.showSpinner) {
              return MainFrame(
                showDecorationLayer: false,
                child: ColoredBox(
                  color: PublicProfilePixelTheme.pageBackground,
                  child: onEmbeddedClose != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PublicProfileBackPill(
                              onTap: () => _popOrClose(context),
                            ),
                            const Expanded(child: _ProfileScreenShimmer()),
                          ],
                        )
                      : const _ProfileScreenShimmer(),
                ),
              );
            }
            if (model.showError) {
              return MainFrame(
                showDecorationLayer: false,
                child: ColoredBox(
                  color: PublicProfilePixelTheme.pageBackground,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (onEmbeddedClose != null)
                        PublicProfileBackPill(
                          onTap: () => _popOrClose(context),
                        ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: context.padSym(h: 24),
                            child: Text(
                              model.displayError,
                              textAlign: TextAlign.center,
                              style: t.text14W400.copyWith(color: c.greyDark),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return MainFrame(
              showDecorationLayer: false,
              child: _buildPixelProfile(context, model),
            );
          },
        ),
      ),
    );
  }
}

class _MobilePublicProfileShimmer extends StatelessWidget {
  const _MobilePublicProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: context.padSym(h: 20).copyWith(bottom: context.h(32)),
      children: [
        const Center(
          child: ShimmerBox(width: 96, height: 96, shape: BoxShape.circle),
        ),
        SizedBox(height: context.h(14)),
        const Center(child: ShimmerBox(width: 170, height: 18)),
        SizedBox(height: context.h(10)),
        const Center(child: ShimmerBox(width: 140, height: 12)),
        SizedBox(height: context.h(20)),
        Row(
          children: const [
            Expanded(child: ShimmerBox(height: 84)),
            SizedBox(width: 10),
            Expanded(child: ShimmerBox(height: 84)),
            SizedBox(width: 10),
            Expanded(child: ShimmerBox(height: 84)),
            SizedBox(width: 10),
            Expanded(child: ShimmerBox(height: 84)),
          ],
        ),
        SizedBox(height: context.h(18)),
        const ShimmerBox(width: 90, height: 16),
        SizedBox(height: context.h(12)),
        const ShimmerBox(height: 52),
        SizedBox(height: context.h(10)),
        const ShimmerBox(height: 52),
      ],
    );
  }
}

class _ProfileScreenShimmer extends StatelessWidget {
  const _ProfileScreenShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: context.padSym(h: 20).copyWith(bottom: context.h(32)),
      children: [
        const Center(
          child: ShimmerBox(width: 96, height: 96, shape: BoxShape.circle),
        ),
        SizedBox(height: context.h(14)),
        const Center(child: ShimmerBox(width: 170, height: 18)),
        SizedBox(height: context.h(10)),
        const Center(child: ShimmerBox(width: 140, height: 12)),
        SizedBox(height: context.h(16)),
        const ShimmerBox(height: 56, radius: 28),
        SizedBox(height: context.h(12)),
        const ShimmerBox(height: 44, radius: 24),
        SizedBox(height: context.h(20)),
        Row(
          children: const [
            Expanded(child: ShimmerBox(height: 84)),
            SizedBox(width: 10),
            Expanded(child: ShimmerBox(height: 84)),
            SizedBox(width: 10),
            Expanded(child: ShimmerBox(height: 84)),
            SizedBox(width: 10),
            Expanded(child: ShimmerBox(height: 84)),
          ],
        ),
        SizedBox(height: context.h(18)),
        const ShimmerBox(width: 90, height: 16),
        SizedBox(height: context.h(12)),
        const ShimmerBox(height: 52),
        SizedBox(height: context.h(10)),
        const ShimmerBox(height: 52),
      ],
    );
  }
}

class _RatePlayerSheet extends StatefulWidget {
  const _RatePlayerSheet({required this.model});

  final PublicProfileViewModel model;

  @override
  State<_RatePlayerSheet> createState() => _RatePlayerSheetState();
}

class _RatePlayerSheetState extends State<_RatePlayerSheet> {
  final TextEditingController _controller = TextEditingController();
  int _selectedStars = 0;
  bool _isSubmittingLocal = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmittingLocal || widget.model.isSubmittingReview) return;
    final comment = _controller.text.trim();

    if (_selectedStars <= 0) {
      AppSnackBar.show(AppText.reviewValidationRating);
      return;
    }
    if (comment.isEmpty) {
      AppSnackBar.show(AppText.reviewValidationComment);
      return;
    }

    setState(() => _isSubmittingLocal = true);
    final ok = await widget.model.submitReview(
      rating: _selectedStars,
      comment: comment,
    );
    if (mounted) {
      setState(() => _isSubmittingLocal = false);
    }
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
      AppSnackBar.show(AppText.reviewSubmitSuccess);
      return;
    }

    AppSnackBar.show(
      widget.model.submitReviewError ?? 'Failed to submit review',
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: context.w(20),
          right: context.w(20),
          top: context.h(20),
          bottom: MediaQuery.of(context).viewInsets.bottom + context.h(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: NormalText(
                    titleText:
                        '${AppText.ratingUserPrefix}${widget.model.displayName}',
                    maxLines: 1,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: c.onSurface,
                    size: context.w(24),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(18)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final active = index < _selectedStars;
                return GestureDetector(
                  onTap: () => setState(() => _selectedStars = index + 1),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(3)),
                    child: Icon(
                      Icons.star_rounded,
                      size: context.w(32),
                      color: active ? c.primary : const Color(0xFFDADADA),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: context.h(20)),
            Container(
              height: context.h(120),
              padding: context.padAll(16),
              decoration: BoxDecoration(
                color: c.blue10,
                borderRadius: BorderRadius.circular(context.radius(12)),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: t.text16W500.copyWith(color: c.onSurface),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: AppText.writeYourExperience,
                  hintStyle: t.text16W500.copyWith(color: c.greylight),
                ),
              ),
            ),
            SizedBox(height: context.h(18)),
            CustomButton(
              text: AppText.submitReview,

              isLoading: widget.model.isSubmittingReview || _isSubmittingLocal,
              color: widget.model.canRateProfile ? c.primary : c.greylight,
              colorText: c.onPrimary,
              onTap: widget.model.canRateProfile
                  ? _submit
                  : () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(seconds: 1), () {
                        AppSnackBar.show("You cannot rate your own profile");
                      });
                    },
            ),
          ],
        ),
      ),
    );
  }
}
