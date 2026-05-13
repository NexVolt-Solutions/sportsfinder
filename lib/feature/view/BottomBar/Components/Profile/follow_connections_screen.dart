import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/follow_connections_args.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/Data/model/follow_connection_user.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/follow_connections_view_model.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/app_dialog.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

/// Followers or Following list — pixel-aligned with design (search, rows, actions).
class FollowConnectionsScreen extends StatelessWidget {
  const FollowConnectionsScreen({
    super.key,
    required this.mode,
    this.args,
    this.onEmbeddedClose,
  });

  final FollowConnectionsMode mode;
  final FollowConnectionsArgs? args;

  /// Web profile split shell: back closes the pane instead of [Navigator.pop].
  final VoidCallback? onEmbeddedClose;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FollowConnectionsViewModel(mode, args: args),
      child: _FollowConnectionsScaffold(onEmbeddedClose: onEmbeddedClose),
    );
  }
}

class _FollowConnectionsScaffold extends StatelessWidget {
  const _FollowConnectionsScaffold({this.onEmbeddedClose});

  final VoidCallback? onEmbeddedClose;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FollowConnectionsViewModel>();
    final c = context.appColors;
    final title = vm.mode == FollowConnectionsMode.followers
        ? AppText.followers
        : AppText.following;
    final showCount =
        !vm.isLoading && vm.errorMessage == null && vm.visibleUsers.isNotEmpty;
    final appBarTitle =
        showCount ? '$title (${vm.visibleUsers.length})' : title;

    return Scaffold(
      body: MainFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: context.padSym(h: 20),
              child: AppBarWidget(
                title: appBarTitle,
                onLeadingTap:
                    onEmbeddedClose ?? () => Navigator.pop(context),
              ),
            ),

            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: context.padSym(h: 20),
                        child: NormalText(
                          titleText:
                              vm.errorMessage ?? 'Error loading followers',
                          titleAlign: TextAlign.center,
                          titleStyle: context.appText.style(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: c.greylight,
                          ),
                        ),
                      ),
                    )
                  : vm.visibleUsers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: context.padSym(h: 20),
                        child: NormalText(
                          titleText: vm.emptyStateMessage,
                          titleAlign: TextAlign.center,
                          titleStyle: context.appText.style(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: c.greylight,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: context.padSym(h: 20),
                      itemCount: vm.visibleUsers.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        thickness: 1,
                        color: c.greylight.withValues(alpha: 0.25),
                      ),
                      itemBuilder: (context, index) {
                        final user = vm.visibleUsers[index];
                        return _ConnectionUserRow(user: user);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionUserRow extends StatelessWidget {
  const _ConnectionUserRow({required this.user});

  final FollowConnectionUser user;

  static double _avatarGap(BuildContext context) =>
      context.w(48) + context.w(14);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FollowConnectionsViewModel>();
    final c = context.appColors;

    final nameBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          user.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appText.style(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: c.onSurface,
          ),
        ),
        if (user.subtitle != null && user.subtitle!.trim().isNotEmpty) ...[
          SizedBox(height: context.h(4)),
          Text(
            user.subtitle!.trim(),
            maxLines: vm.mode == FollowConnectionsMode.followers ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: context.appText.style(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: c.greylight,
              height: 1.25,
            ),
          ),
        ],
      ],
    );

    if (vm.mode == FollowConnectionsMode.followers) {
      return Padding(
        padding: context.padSym(v: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.w(48),
                  height: context.w(48),
                  decoration: BoxDecoration(
                    color: c.blue10,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    user.initial,
                    style: context.appText.style(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: c.primary,
                    ),
                  ),
                ),
                SizedBox(width: context.w(14)),
                Expanded(child: nameBlock),
              ],
            ),
            SizedBox(height: context.h(12)),
            Padding(
              padding: EdgeInsets.only(left: _avatarGap(context)),
              child: Align(
                alignment: Alignment.centerRight,
                child: _FollowersTrailing(user: user),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: context.padSym(v: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: context.w(48),
            height: context.w(48),
            decoration: BoxDecoration(color: c.blue10, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              user.initial,
              style: context.appText.style(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.primary,
              ),
            ),
          ),
          SizedBox(width: context.w(14)),
          Expanded(child: nameBlock),
          _FollowingTrailing(user: user),
        ],
      ),
    );
  }
}

class _FollowersTrailing extends StatelessWidget {
  const _FollowersTrailing({required this.user});

  final FollowConnectionUser user;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FollowConnectionsViewModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (vm.canRemoveFollowers) ...[
          _RemoveFollowerButton(user: user),
          SizedBox(width: context.w(10)),
        ],
        _FollowBackChip(user: user),
      ],
    );
  }
}

Future<void> _confirmRemoveFollower(
  BuildContext context,
  FollowConnectionUser user,
) async {
  final confirmed = await showAppDialog<bool>(
    context,
    title: AppText.removeFollowerTitle,
    message: AppText.removeFollowerMessage,
    actions: [
      AppDialogAction(
        label: AppText.cancel,
        onPressed: (dialogContext) => Navigator.pop(dialogContext, false),
      ),
      AppDialogAction(
        label: AppText.remove,
        isDestructive: true,
        onPressed: (dialogContext) => Navigator.pop(dialogContext, true),
      ),
    ],
  );
  if (confirmed != true || !context.mounted) return;
  final vm = context.read<FollowConnectionsViewModel>();
  final ok = await vm.removeFollowerApi(user);
  if (!context.mounted) return;
  if (ok) {
    AppSnackBar.show('Follower removed');
  } else {
    AppSnackBar.show(
      vm.getRemoveFollowerError(user.id) ?? 'Could not remove follower',
    );
  }
}

class _RemoveFollowerButton extends StatelessWidget {
  const _RemoveFollowerButton({required this.user});

  final FollowConnectionUser user;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FollowConnectionsViewModel>();
    final c = context.appColors;
    final busy = vm.isRemovingFollower(user.id);
    final err = vm.getRemoveFollowerError(user.id);

    return TextButton(
      onPressed: busy
          ? null
          : () async {
              if (err != null) {
                final vm = context.read<FollowConnectionsViewModel>();
                final ok = await vm.removeFollowerApi(user);
                if (!context.mounted) return;
                if (ok) {
                  AppSnackBar.show('Follower removed');
                } else {
                  AppSnackBar.show(
                    vm.getRemoveFollowerError(user.id) ??
                        'Could not remove follower',
                  );
                }
              } else {
                await _confirmRemoveFollower(context, user);
              }
            },
      style: TextButton.styleFrom(
        foregroundColor: err != null ? c.greylight : c.error,
        padding: EdgeInsets.symmetric(
          horizontal: context.w(6),
          vertical: context.h(4),
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      child: busy
          ? SizedBox(
              width: context.w(16),
              height: context.w(16),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: c.error,
              ),
            )
          : Text(
              err != null ? 'Retry' : AppText.remove,
              style: context.appText.style(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

class _FollowBackChip extends StatelessWidget {
  const _FollowBackChip({required this.user});

  final FollowConnectionUser user;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FollowConnectionsViewModel>();
    final c = context.appColors;

    if (vm.didFollowBack(user)) {
      return Padding(
        padding: EdgeInsets.only(right: context.w(4)),
        child: NormalText(
          titleText: AppText.following,
          titleStyle: context.appText.style(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: c.greylight,
          ),
        ),
      );
    }

    final isFollowing = vm.isFollowingUser(user.id);
    final error = vm.getFollowUserError(user.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isFollowing ? null : () => vm.followBackUser(user),
        borderRadius: BorderRadius.circular(context.radius(10)),
        child: Ink(
          decoration: BoxDecoration(
            color: error != null ? c.surface : c.primary,
            borderRadius: BorderRadius.circular(context.radius(10)),
            boxShadow: [
              BoxShadow(
                color: (error != null ? c.surface : c.primary).withValues(
                  alpha: 0.35,
                ),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: context.padSym(h: 10, v: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isFollowing)
                  SizedBox(
                    width: context.w(16),
                    height: context.w(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        error != null ? c.greylight : c.onPrimary,
                      ),
                    ),
                  )
                else if (error != null)
                  Icon(
                    Icons.error_outline,
                    size: context.w(16),
                    color: c.greylight,
                  )
                else
                  Icon(
                    Icons.person_add,
                    size: context.w(16),
                    color: c.onPrimary,
                  ),
                SizedBox(width: context.w(4)),
                Text(
                  error != null
                      ? 'Retry'
                      : isFollowing
                      ? 'Following...'
                      : AppText.followBack,
                  style: context.appText.style(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: error != null ? c.greylight : c.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FollowingTrailing extends StatelessWidget {
  const _FollowingTrailing({required this.user});

  final FollowConnectionUser user;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FollowConnectionsViewModel>();
    final c = context.appColors;

    if (!vm.canManageFollowingActions) {
      return Padding(
        padding: EdgeInsets.only(left: context.w(8)),
        child: NormalText(
          titleText: AppText.following,
          titleStyle: context.appText.style(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: c.greylight,
          ),
        ),
      );
    }

    if (!vm.isStillFollowing(user)) {
      return Padding(
        padding: EdgeInsets.only(left: context.w(8)),
        child: _FollowingFollowChip(user: user),
      );
    }

    final isUnfollowing = vm.isUnfollowingUser(user.id);
    final error = vm.getUnfollowUserError(user.id);

    return Padding(
      padding: EdgeInsets.only(left: context.w(8)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUnfollowing ? null : () => vm.unfollowUserApi(user),
          borderRadius: BorderRadius.circular(context.radius(10)),
          child: Ink(
            decoration: BoxDecoration(
              color: c.surface,
              border: Border.all(
                color: error != null
                    ? c.greylight.withValues(alpha: 0.45)
                    : c.primary.withValues(alpha: 0.55),
              ),
              borderRadius: BorderRadius.circular(context.radius(10)),
            ),
            child: Padding(
              padding: context.padSym(h: 12, v: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isUnfollowing)
                    SizedBox(
                      width: context.w(18),
                      height: context.w(18),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(c.primary),
                      ),
                    )
                  else if (error != null)
                    Icon(
                      Icons.error_outline,
                      size: context.w(18),
                      color: c.greylight,
                    )
                  else
                    Icon(
                      Icons.person_remove_alt_1_outlined,
                      size: context.w(18),
                      color: c.primary,
                    ),
                  SizedBox(width: context.w(6)),
                  Text(
                    error != null
                        ? 'Retry'
                        : isUnfollowing
                        ? 'Unfollowing...'
                        : AppText.unfollow,
                    style: context.appText.style(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: error != null ? c.greylight : c.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FollowingFollowChip extends StatelessWidget {
  const _FollowingFollowChip({required this.user});

  final FollowConnectionUser user;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FollowConnectionsViewModel>();
    final c = context.appColors;

    final isFollowing = vm.isFollowingUser(user.id);
    final error = vm.getFollowUserError(user.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isFollowing ? null : () => vm.followAgainFromFollowingList(user),
        borderRadius: BorderRadius.circular(context.radius(10)),
        child: Ink(
          decoration: BoxDecoration(
            color: error != null ? c.surface : c.primary,
            borderRadius: BorderRadius.circular(context.radius(10)),
            boxShadow: [
              BoxShadow(
                color: (error != null ? c.surface : c.primary).withValues(
                  alpha: 0.35,
                ),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: context.padSym(h: 10, v: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isFollowing)
                  SizedBox(
                    width: context.w(16),
                    height: context.w(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        error != null ? c.greylight : c.onPrimary,
                      ),
                    ),
                  )
                else if (error != null)
                  Icon(
                    Icons.error_outline,
                    size: context.w(16),
                    color: c.greylight,
                  )
                else
                  Icon(
                    Icons.person_add,
                    size: context.w(16),
                    color: c.onPrimary,
                  ),
                SizedBox(width: context.w(4)),
                Text(
                  error != null
                      ? 'Retry'
                      : isFollowing
                      ? 'Following...'
                      : AppText.follow,
                  style: context.appText.style(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: error != null ? c.greylight : c.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
