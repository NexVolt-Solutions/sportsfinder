import 'package:flutter/material.dart';
import 'package:sport_finding/Data/model/follow_connections_args.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/follow_connections_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/follow_connections_view_model.dart';

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({super.key, this.args, this.onEmbeddedClose});

  final FollowConnectionsArgs? args;
  final VoidCallback? onEmbeddedClose;

  @override
  Widget build(BuildContext context) {
    return FollowConnectionsScreen(
      mode: FollowConnectionsMode.following,
      args: args,
      onEmbeddedClose: onEmbeddedClose,
    );
  }
}
