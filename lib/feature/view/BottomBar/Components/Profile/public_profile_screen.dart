import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/Data/model/public_profile_args.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/profile_detail_widgets.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/public_profile_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({super.key, this.args});

  /// From [RouteSettings.arguments]; avoids [ModalRoute.of] inside Provider `create`.
  final PublicProfileArgs? args;

  void _showRateSheet(BuildContext context, PublicProfileViewModel model) {
    final c = context.appColors;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radiusR(14)),
        ),
      ),
      builder: (sheetContext) => _RatePlayerSheet(model: model),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PublicProfileViewModel(args: args),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: MainFrame(
          child: Consumer<PublicProfileViewModel>(
            builder: (context, model, _) {
              final c = context.appColors;
              final t = context.appText;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: context.padSym(h: 20),
                    child: AppBarWidget(
                      title: AppText.publicProfile,
                      onLeadingTap: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: model.showSpinner
                        ? Center(
                            child: CircularProgressIndicator(color: c.primary),
                          )
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
                              SizedBox(height: context.h(20)),
                              _FollowMessageRow(
                                onFollow: () => model.onFollowTap(context),
                                onMessage: () => model.onMessageTap(context),
                                isFollowing: model.isFollowing,
                                isFollowLoading: model.isFollowLoading,
                              ),
                              SizedBox(height: context.h(12)),
                              _RatePlayerButton(
                                onTap: () => _showRateSheet(context, model),
                              ),
                              SizedBox(height: context.h(20)),
                              ProfileDetailStatsRow(
                                followersCount: model.followersCount,
                                followingCount: model.followingCount,
                                ratingValue: model.ratingValue,
                                onFollowersTap: () =>
                                    model.openFollowers(context),
                                onFollowingTap: () =>
                                    model.openFollowing(context),
                                onRatingTap: model.isOwnProfile
                                    ? null
                                    : () => _showRateSheet(context, model),
                              ),
                              SizedBox(height: context.h(16)),
                              NormalText(
                                titleText: AppText.mySports,
                                titleStyle: t.text16Bold.copyWith(
                                  color: c.greyDark,
                                ),
                              ),
                              ...model.publicSportsForDisplay.map(
                                (s) => ProfilePrivateSportRow(
                                  sportName: s.name,
                                  skillLabel: s.skill,
                                ),
                              ),
                              SizedBox(height: context.h(8)),
                              NormalText(
                                titleText: AppText.reviews,
                                titleStyle: t.text16Bold.copyWith(
                                  color: c.greyDark,
                                ),
                              ),
                              ProfileDetailReviewCard(
                                reviewAuthor: model.reviewAuthorForDisplay,
                                reviewDate: model.reviewDateForDisplay,
                                reviewBody: model.reviewBodyForDisplay,
                                reviewInitial: model.reviewInitial,
                              ),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
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
  final TextEditingController _matchIdController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  int _selectedStars = 0;

  @override
  void initState() {
    super.initState();
    final initialMatchId = widget.model.initialMatchId;
    if (initialMatchId.isNotEmpty) {
      _matchIdController.text = initialMatchId;
    }
  }

  @override
  void dispose() {
    _matchIdController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final context = this.context;
    final messenger = ScaffoldMessenger.of(context);
    final matchId = _matchIdController.text.trim();
    final comment = _controller.text.trim();
    if (matchId.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppText.reviewValidationMatchId)),
      );
      return;
    }
    if (_selectedStars <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppText.reviewValidationRating)),
      );
      return;
    }
    if (comment.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppText.reviewValidationComment)),
      );
      return;
    }

    final ok = await widget.model.submitReview(
      matchId: matchId,
      rating: _selectedStars,
      comment: comment,
    );
    if (!mounted) return;

    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppText.reviewSubmitSuccess)),
      );
      Navigator.of(this.context).pop();
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          widget.model.submitReviewError ?? 'Failed to submit review',
        ),
      ),
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
              padding: context.padSym(h: 14, v: 4),
              decoration: BoxDecoration(
                color: c.blue10,
                borderRadius: BorderRadius.circular(context.radiusR(12)),
              ),
              child: TextField(
                controller: _matchIdController,
                style: t.text16W500.copyWith(color: c.onSurface),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: AppText.matchId,
                  hintText: AppText.matchIdHint,
                  hintStyle: t.text14W400.copyWith(color: c.greylight),
                ),
              ),
            ),
            SizedBox(height: context.h(12)),
            Container(
              height: context.h(120),
              padding: context.padAll(16),
              decoration: BoxDecoration(
                color: c.blue10,
                borderRadius: BorderRadius.circular(context.radiusR(12)),
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
              text: widget.model.isSubmittingReview
                  ? '${AppText.submitReview}...'
                  : AppText.submitReview,
              color: c.primary,
              colorText: c.onPrimary,
              onTap: widget.model.isSubmittingReview ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowMessageRow extends StatelessWidget {
  const _FollowMessageRow({
    required this.onFollow,
    required this.onMessage,
    required this.isFollowing,
    required this.isFollowLoading,
  });

  final Future<void> Function() onFollow;
  final VoidCallback onMessage;
  final bool isFollowing;
  final bool isFollowLoading;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: isFollowing || isFollowLoading ? null : () => onFollow(),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(30),
            ),
            color: isFollowing ? Colors.white : c.primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  if (isFollowLoading)
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          isFollowing ? c.primary : c.onPrimary,
                        ),
                      ),
                    )
                  else
                    Icon(
                      isFollowing ? Icons.check : Icons.person_add_alt_1,
                      size: 22,
                      color: isFollowing ? c.primary : c.onPrimary,
                    ),
                  SizedBox(width: context.w(4)),
                  NormalText(
                    titleText: isFollowLoading
                        ? '${AppText.following}...'
                        : isFollowing
                        ? AppText.following
                        : AppText.follow,
                    titleColor: isFollowing ? c.primary : c.onPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: onMessage,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  SvgPicture.asset(AppAssets.chat, width: 22, height: 22),
                  SizedBox(width: context.w(4)),
                  NormalText(
                    titleText: AppText.message,
                    titleColor: c.greyDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RatePlayerButton extends StatelessWidget {
  const _RatePlayerButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return CustomButton(
      text: AppText.ratePlayer,
      color: c.primary,
      radius: BorderRadius.circular(30),
      padding: context.padSym(h: 0, v: 6),
      colorText: c.onPrimary,
      onTap: onTap,
      leading: Icon(Icons.star_rounded, color: c.onPrimary, size: 22),
    );
  }
}
