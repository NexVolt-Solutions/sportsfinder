// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:sport_finding/core/Constants/app_assets.dart';
// import 'package:sport_finding/core/Constants/app_colors.dart';
// import 'package:sport_finding/core/Constants/size_extension.dart';

// class BottomBarScreen extends StatefulWidget {
//   const BottomBarScreen({super.key});

//   @override
//   State<BottomBarScreen> createState() => _BottomBarScreenState();
// }

// class _BottomBarScreenState extends State<BottomBarScreen> {
//   int selectedIndex = 2;

//   void onItemTapped(int index) {
//     setState(() {
//       selectedIndex = index;
//     });
//   }

//   Widget navItem(String iconPath, String label, int index) {
//     bool isSelected = selectedIndex == index;

//     return GestureDetector(
//       onTap: () => onItemTapped(index),
//       child: Column(
//         // mainAxisSize: MainAxisSize.max,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         // mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SvgPicture.asset(
//             iconPath,
//             fit: BoxFit.scaleDown,
//             colorFilter: ColorFilter.mode(
//               isSelected ? AppColors.bluecolor : AppColors.blackcolor,
//               BlendMode.srcIn,
//             ),
//           ),
//           SizedBox(height: context.h(4)),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: context.sp(12),
//               fontWeight: FontWeight.w500,
//               color: isSelected ? AppColors.bluecolor : AppColors.blackcolor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: const Center(child: Text("Home Screen")),

//       bottomNavigationBar: Stack(
//         alignment: Alignment.bottomCenter,
//         children: [
//           Container(
//             height: 75,
//             // padding: context.padSym(h: 24, v: 7),
//             margin: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: AppColors.redcolor,
//               borderRadius: BorderRadius.circular(20),
//             ),

//             // child: Padding(
//             //   padding: EdgeInsetsGeometry.only(
//             //     left: context.w(20),
//             //     right: context.w(30),
//             //   ),
//             //   child: Row(
//             //     // mainAxisAlignment: MainAxisAlignment.spaceAround,
//             //     children: [
//             //       Row(
//             //         children: [
//             //           Column(
//             //             mainAxisAlignment: MainAxisAlignment.center,
//             //             children: [
//             //               SvgPicture.asset(
//             //                 AppAssets.matchesIcon,
//             //                 fit: BoxFit.scaleDown,
//             //               ),
//             //               Text('Matches'),
//             //             ],
//             //           ),

//             //           // SizedBox(width: context.w(40)),
//             //           Column(
//             //             mainAxisAlignment: MainAxisAlignment.center,
//             //             children: [
//             //               SvgPicture.asset(
//             //                 AppAssets.matchesIcon,
//             //                 fit: BoxFit.scaleDown,
//             //               ),
//             //               Text('Matches'),
//             //             ],
//             //           ),
//             //         ],
//             //       ),
//             //       Padding(
//             //         padding: EdgeInsetsGeometry.only(
//             //           left: context.w(30),
//             //           right: context.w(30),
//             //         ),
//             //         child: Row(
//             //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             //           children: [
//             //             Column(
//             //               mainAxisAlignment: MainAxisAlignment.center,
//             //               children: [
//             //                 SvgPicture.asset(
//             //                   AppAssets.matchesIcon,
//             //                   fit: BoxFit.scaleDown,
//             //                 ),
//             //                 Text('Matches'),
//             //               ],
//             //             ),
//             //             // SizedBox(width: context.w(40)),
//             //             Column(
//             //               mainAxisAlignment: MainAxisAlignment.center,
//             //               children: [
//             //                 SvgPicture.asset(
//             //                   AppAssets.matchesIcon,
//             //                   fit: BoxFit.scaleDown,
//             //                 ),
//             //                 Text('Matches'),
//             //               ],
//             //             ),
//             //           ],
//             //         ),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//           ),

//           // GestureDetector(
//           //   onTap: () => onItemTapped(2),
//           //   child: SvgPicture.asset(
//           //     AppAssets.homeIcon,
//           //     // height: 60,
//           //     // width: 60,
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int selectedIndex = 2;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // BODY CONTENT CHANGER
  Widget getBody() {
    switch (selectedIndex) {
      case 0:
        return const Center(child: Text("Matches"));
      case 1:
        return const Center(child: Text("Discover"));
      case 2:
        return const Center(child: Text("Home"));
      case 3:
        return const Center(child: Text("Chat"));
      case 4:
        return const Center(child: Text("Profile"));
      default:
        return const Center(child: Text("Home"));
    }
  }

  Widget navItem(String iconPath, String label, int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: SizedBox(
        width: context.w(65),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              fit: BoxFit.scaleDown,
              colorFilter: ColorFilter.mode(
                isSelected ? AppColors.bluecolor : AppColors.blackcolor,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: context.h(4)),
            Text(
              label,
              style: TextStyle(
                fontSize: context.sp(12),
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.bluecolor : AppColors.blackcolor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),

      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 75,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.redcolor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                navItem(AppAssets.matchesIcon, "Matches", 0),
                navItem(AppAssets.searchBarIcon, "Discover", 1),

                SizedBox(width: context.w(50)),

                navItem(AppAssets.chatIcon, "Chat", 3),
                navItem(AppAssets.profileIcon, "Profile", 4),
              ],
            ),
          ),

          // HOME BUTTON
          GestureDetector(
            onTap: () => onItemTapped(2),
            child: SvgPicture.asset(AppAssets.homeIcon),
          ),
        ],
      ),
    );
  }
}
