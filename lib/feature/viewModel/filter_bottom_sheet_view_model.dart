import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/feature/model/match_filters.dart';

/// ViewModel for [FilterBottomSheet].
///
/// Keeps all user selections (sport/skill/distance/date/time) so the UI is
/// purely a renderer and stays consistent across all screens.
class FilterBottomSheetViewModel extends ChangeNotifier {
  FilterBottomSheetViewModel();

  int? selectedSportIndex;
  int? selectedSkillIndex;

  /// UI initial value matches the design (thumb near `10 km`),
  /// but we treat it as "no distance filter" until the user moves the slider.
  double distance = 10.0;
  bool distanceEnabled = false;

  final List<String> skillLevels = const ['Beginner', 'Intermediate', 'Advanced'];

  final List<SportType> sports = [
    SportType(name: 'Football', icon: AppAssets.footBallIcon),
    SportType(name: 'Basketball', icon: AppAssets.basketBallIcon),
    SportType(name: 'Volleyball', icon: AppAssets.volleyBallIcon),
    SportType(name: 'Tennis', icon: AppAssets.tableTennisIcon),
  ];

  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  void setDate(DateTime date) {
    selectedDate = date;
    dateController.text = '${date.day}/${_getMonthName(date.month)}/${date.year}';
    notifyListeners();
  }

  void setTime(TimeOfDay time, BuildContext context) {
    selectedTime = time;
    timeController.text = time.format(context);
    notifyListeners();
  }

  void toggleSport(int index) {
    selectedSportIndex = selectedSportIndex == index ? null : index;
    notifyListeners();
  }

  void toggleSkill(int index) {
    selectedSkillIndex = selectedSkillIndex == index ? null : index;
    notifyListeners();
  }

  void setDistance(double v) {
    distance = v;
    distanceEnabled = true;
    notifyListeners();
  }

  void reset() {
    selectedSportIndex = null;
    selectedSkillIndex = null;
    distance = 10.0;
    distanceEnabled = false;
    selectedDate = null;
    selectedTime = null;
    dateController.clear();
    timeController.clear();
    notifyListeners();
  }

  FilterData buildFilterData() {
    final effectiveDistance =
        distanceEnabled ? distance : kMaxFilterDistanceKm;
    return FilterData(
      sportIndex: selectedSportIndex,
      skillLevel: selectedSkillIndex != null ? skillLevels[selectedSkillIndex!] : null,
      distance: effectiveDistance,
      time: selectedTime,
      date: selectedDate,
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }
}

