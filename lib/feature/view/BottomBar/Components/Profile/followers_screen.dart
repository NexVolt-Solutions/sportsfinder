import 'package:flutter/material.dart';
import 'package:sport_finding/Data/model/follow_connections_args.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/follow_connections_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/follow_connections_view_model.dart';

class FollowersScreen extends StatelessWidget {
  const FollowersScreen({super.key, this.args});

  final FollowConnectionsArgs? args;

  @override
  Widget build(BuildContext context) {
    return FollowConnectionsScreen(
      mode: FollowConnectionsMode.followers,
      args: args,
    );
  }
}
