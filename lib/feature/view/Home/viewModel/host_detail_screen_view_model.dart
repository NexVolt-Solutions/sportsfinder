import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_text.dart';

class HostDetailScreenViewModel extends ChangeNotifier {
  int selectedIndex = 0;
  List buttonName = [AppText.overview, AppText.invitePlayers, AppText.location];
  void changeIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
