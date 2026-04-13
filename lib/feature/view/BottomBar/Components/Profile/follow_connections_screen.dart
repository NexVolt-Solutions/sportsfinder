import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  const FollowConnectionsScreen({super.key, required this.mode});

  final FollowConnectionsMode mode;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FollowConnectionsViewModel(mode),
      child: const _FollowConnectionsScaffold(),
    );
  }
}

class _FollowConnectionsScaffold extends StatelessWidget {
  const _FollowConnectionsScaffold();

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
                onLeadingTap: () => Navigator.pop(context),
              ),
            ),

            Expanded(
              child: vm.visibleUsers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: context.padSym(h: 20),
                        child: NormalText(
                          titleText: AppText.noConnectionsMatchSearch,
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => vm.followBack(user),
        borderRadius: BorderRadius.circular(context.radiusR(10)),
        child: Ink(
          decoration: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(context.radiusR(10)),
            boxShadow: [
              BoxShadow(
                color: c.primary.withValues(alpha: 0.35),
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
                Icon(Icons.person_add, size: context.w(18), color: c.onPrimary),
                SizedBox(width: context.w(6)),
                Text(
                  AppText.followBack,
                  style: context.appText.style(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.onPrimary,
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

    return OutlinedButton(
      onPressed: () => vm.unfollow(user),
      style: OutlinedButton.styleFrom(
        foregroundColor: c.greyDark,
        side: BorderSide(color: c.greylight.withValues(alpha: 0.45)),
        padding: context.padSym(h: 12, v: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.radiusR(10)),
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, size: context.w(18), color: c.greyDark),
          SizedBox(width: context.w(6)),
          Text(
            AppText.followed,
            style: context.appText.style(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.greyDark,
            ),
          ),
        ],
      ),
    );
  }
}
