import 'package:flutter/material.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/oauth_uri_bootstrap.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/bottom_bar_screen_view_model.dart';

/// OAuth redirect target (e.g. `/auth-callback?next=/profile#access_token=...`).
class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handle());
  }

  Future<void> _handle() async {
    final ok = await consumeOAuthTokensFromCurrentUri();
    if (!mounted) return;

    if (!ok) {
      Navigator.pushReplacementNamed(context, RoutesName.LoginScreen);
      return;
    }

    final next = Uri.base.queryParameters['next'] ?? '';
    final tab = mapNextPathToBottomBarTab(next);
    Navigator.pushReplacementNamed(
      context,
      RoutesName.bottomBarScreen,
      arguments: tab,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Maps marketing-site paths like `/profile` to bottom bar indices.
int mapNextPathToBottomBarTab(String next) {
  final raw = next.trim();
  if (raw.isEmpty) return BottomBarScreenViewModel.homeIndex;

  String path = raw;
  if (path.contains('://')) {
    try {
      path = Uri.parse(path).path;
    } catch (_) {
      path = raw;
    }
  }
  if (!path.startsWith('/')) path = '/$path';
  path = path.toLowerCase();

  switch (path) {
    case '/profile':
      return 4;
    case '/discover':
      return 1;
    case '/matches':
    case '/my-matches':
      return 0;
    case '/chat':
      return 3;
    case '/home':
    case '/':
      return BottomBarScreenViewModel.homeIndex;
    default:
      return BottomBarScreenViewModel.homeIndex;
  }
}
