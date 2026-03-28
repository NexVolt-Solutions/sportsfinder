// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sport_finding/core/Constants/app_text.dart';
// import 'package:sport_finding/core/Constants/app_theme.dart';
// import 'package:sport_finding/core/Constants/size_extension.dart';
// import 'package:sport_finding/core/Routes/routes_name.dart';
// import 'package:sport_finding/feature/model/discovery_match.dart';
// import 'package:sport_finding/feature/view/BottomBar/ViewModel/all_member_screen_view_model.dart';
// import 'package:sport_finding/feature/widget/app_bar_widget.dart';
// import 'package:sport_finding/feature/widget/mainframe.dart';
// import 'package:sport_finding/feature/widget/normal_text.dart';
// import 'package:sport_finding/feature/widget/person_invited_card.dart';

// class AllMemberScreen extends StatefulWidget {
//   const AllMemberScreen({super.key});

//   @override
//   State<AllMemberScreen> createState() => _AllMemberScreenState();
// }

// class _AllMemberScreenState extends State<AllMemberScreen> {
//   @override
//   Widget build(BuildContext context) {
//     // final match = ModalRoute.of(context)!.settings.arguments as DiscoveryMatch;

//     return Consumer<AllMemberScreenViewModel>(
//       builder: (context, model, child) => Scaffold(
//         body: MainFrame(
//           child: Padding(
//             padding: context.padSym(h: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: context.h(20)),

//                 AppBarWidget(
//                   onTapFirst: () => Navigator.pop(context),
//                   title: AppText.sportFinding,
//                 ),

//                 SizedBox(height: context.h(20)),

//                 NormalText(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   titleText: AppText.invitationSent,
//                   titleStyle: context.appText.text16W500,
//                   titleColor: context.appColors.surface,
//                 ),

//                 SizedBox(height: context.h(8)),

//                 SizedBox(
//                   height: context.h(200),
//                   child: ListView.builder(
//                     itemCount: 5,
//                     //  match.players.length,
//                     itemBuilder: (context, index) {
//                       return PersonInvitedCard(
//                         cardOnTap: () {
//                           // print("Clicked Match ID: ${match.id}");
//                         },
//                         playerName: 'Khan',
//                         matchLevel: AppText.advanced,
//                         matchName: 'FootBall',
//                         destance: "10 km",
//                         ontap: () {
//                           // Navigator.pushNamed(
//                           //   context,
//                           //   RoutesName.userMatchDetailsScreen,
//                           //   arguments: match,
//                           // );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view/BottomBar/Components/Chat/chat_screen.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/all_member_screen_view_model.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/chat_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/filter_bottom_sheet_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/person_invited_card.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';

class AllMemberScreen extends StatefulWidget {
  const AllMemberScreen({super.key});

  @override
  State<AllMemberScreen> createState() => _AllMemberScreenState();
}

class _AllMemberScreenState extends State<AllMemberScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AllMemberScreenViewModel>(
      builder: (context, model, child) => Scaffold(
        body: MainFrame(
          child: Padding(
            padding: context.padSym(h: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.h(20)),

                AppBarWidget(
                  onTapFirst: () => Navigator.pop(context),
                  title: AppText.sportFinding,
                ),

                // SizedBox(height: context.h(16)),
                NormalText(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  titleText: AppText.allMembers,
                ),

                SizedBox(height: context.h(8)),

                SearchBarWidget(
                  isShow: true,
                  onChanged: (text) {
                    model.searchMatches(text);
                  },
                  onFilterTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return FilterBottomSheet(
                          onApply: (filterData) {
                            // Handle filter application
                            print('Sport Index: ${filterData.sportIndex}');
                            print('Skill Level: ${filterData.skillLevel}');
                            print('Distance: ${filterData.distance} km');
                            print('Time: ${filterData.time?.format(context)}');
                            print('Date: ${filterData.date}');

                            // Apply filters to your ViewModel
                            model.applyFilters(filterData);
                          },
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: context.h(16)),
                // ✅ Use Expanded to fill remaining space
                Expanded(
                  child: ListView.builder(
                    itemCount: 6, // Use actual players
                    itemBuilder: (context, index) {
                      return PersonInvitedCard(
                        // cardOnTap: () {
                        //   // Optional: Do something on card tap
                        //   // print("Clicked Player: ${match.players[index]}");
                        // },
                        cardOnTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider(
                                create: (_) => ChatScreenViewModel(),
                                child: const ChatScreen(),
                              ),
                            ),
                          );
                        },
                        playerName: 'Khan',
                        matchLevel: AppText.advanced,
                        matchName: 'Football',
                        destance:
                            "10 km", // Replace with real data if available
                        ontap: () {
                          // Navigate to User Match Details
                        },
                      );
                    },
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
