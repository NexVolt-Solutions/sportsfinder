import 'package:flutter/material.dart';

class BottomBarScreenViewModel extends ChangeNotifier {
  int _selectedIndex = 2;

  int get selectedIndex => _selectedIndex;

  static const int homeIndex = 2;

  void setSelectedIndex(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  bool get isHomeSelected => _selectedIndex == homeIndex;
}
