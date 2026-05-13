import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/follow_connections_args.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/Data/model/follow_connection_user.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/follow_connections_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
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

    return Scaffold(
      body: MainFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: context.padSym(h: 20),
              child: AppBarWidget(
                title: title,
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FollowConnectionsViewModel>();
    final c = context.appColors;

    return Padding(
      padding: context.padSym(v: 14),
      child: Row(
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
          Expanded(
            child: NormalText(
              titleText: user.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              titleStyle: context.appText.style(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: c.onSurface,
              ),
            ),
          ),
          if (vm.mode == FollowConnectionsMode.followers)
            _FollowersTrailing(user: user)
          else
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
            padding: context.padSym(h: 12, v: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isFollowing)
                  SizedBox(
                    width: context.w(18),
                    height: context.w(18),
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
                    size: context.w(18),
                    color: c.greylight,
                  )
                else
                  Icon(
                    Icons.person_add,
                    size: context.w(18),
                    color: c.onPrimary,
                  ),
                SizedBox(width: context.w(6)),
                Text(
                  error != null
                      ? 'Retry'
                      : isFollowing
                      ? 'Following...'
                      : AppText.followBack,
                  style: context.appText.style(
                    fontSize: 13,
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

    if (!vm.isStillFollowing(user)) {
      return const SizedBox.shrink();
    }

    final isUnfollowing = vm.isUnfollowingUser(user.id);
    final error = vm.getUnfollowUserError(user.id);

    final canUnfollow = vm.canManageFollowingActions;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: !canUnfollow || isUnfollowing
            ? null
            : () => vm.unfollowUserApi(user),
        borderRadius: BorderRadius.circular(context.radius(10)),
        child: Ink(
          decoration: BoxDecoration(
            color: error != null ? c.surface : c.surface,
            border: Border.all(
              color: error != null
                  ? c.greylight.withValues(alpha: 0.45)
                  : c.greylight.withValues(alpha: 0.45),
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
                      valueColor: AlwaysStoppedAnimation(c.greyDark),
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
                    Icons.person_outline,
                    size: context.w(18),
                    color: c.greyDark,
                  ),
                SizedBox(width: context.w(6)),
                Text(
                  error != null
                      ? 'Retry'
                      : isUnfollowing
                      ? 'Unfollowing...'
                      : AppText.following,
                  style: context.appText.style(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: error != null ? c.greylight : c.greyDark,
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
