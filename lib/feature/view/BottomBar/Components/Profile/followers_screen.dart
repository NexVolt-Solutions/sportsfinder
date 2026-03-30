import 'package:flutter/material.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Profile/follow_connections_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/follow_connections_view_model.dart';

class FollowersScreen extends StatelessWidget {
  const FollowersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FollowConnectionsScreen(
      mode: FollowConnectionsMode.followers,
    );
  }
}
