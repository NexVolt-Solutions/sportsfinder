import 'package:flutter/material.dart';

class HomeScreenViewModel extends ChangeNotifier {}

class MatchData {
  final String imagePath;
  final String title;

  MatchData({required this.imagePath, required this.title});
}
