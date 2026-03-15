import 'package:flutter/material.dart';

class BottomBarScreenViewModel extends ChangeNotifier {
  int selectedIndex = 2;

  void onItemTapped(int index) {
    selectedIndex = index;
    notifyListeners();
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
}
