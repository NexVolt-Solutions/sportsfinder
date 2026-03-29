import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key, this.embedInBottomBar = false});

  /// When true, [BottomBarScreen] supplies the shared [AppBarWidget].
  final bool embedInBottomBar;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatScreenViewModel(),
      child: Consumer<ChatScreenViewModel>(
        builder: (context, model, _) {
          return Scaffold(
            // 1️⃣ Add the FAB
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, RoutesName.allMemeberScreen);
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.add, color: Colors.white),
            ),
            body: MainFrame(
              child: ListView(
                padding: context.padSym(h: 20),
                children: [
                  if (!widget.embedInBottomBar)
                    AppBarWidget(
                      onTapFirst: () => Navigator.pop(context),
                      title: AppText.sportFinding,
                    ),
                  SizedBox(
                    height: context.h(widget.embedInBottomBar ? 120 : 236),
                  ),
                  SvgPicture.asset(
                    AppAssets.invitedPeopleIcon,
                    fit: BoxFit.scaleDown,
                  ),
                  NormalText(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    titleText: AppText.invitePlayers,
                    subAlign: TextAlign.center,
                    subText: AppText.discoverNearbyPeopleInYourArea,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
