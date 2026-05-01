import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Network/platform_options_store.dart';
import 'package:sport_finding/Data/model/match_filters.dart';

 
class FilterBottomSheetViewModel extends ChangeNotifier {
  FilterBottomSheetViewModel() {
    _load();
  }

  int? selectedSportIndex;
  int? selectedSkillIndex;
 double distance = 10.0;
  bool distanceEnabled = false;

  List<String> skillLevels = [];
  List<SportType> sports = [];
  bool isLoading = true;
  String? loadError;

  Future<void> _load() async {
    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      final o = await PlatformOptionsStore.instance.load();
      skillLevels = List<String>.from(o.skills);
      sports = o.sports
          .map(
            (name) => SportType(name: name, icon: _iconForSportName(name)),
          )
          .toList();
    } catch (e) {
      loadError = e.toString();
      skillLevels = [];
      sports = [];
    }
    isLoading = false;
    notifyListeners();
  }

  void retryOptionsLoad() {
    _load();
  }

  String _iconForSportName(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
        return AppAssets.footBallIcon;
      case 'basketball':
        return AppAssets.basketBallIcon;
      case 'tennis':
        return AppAssets.tableTennisIcon;
      case 'volleyball':
        return AppAssets.volleyBallIcon;
      case 'badminton':
        return AppAssets.tableTennisIcon;
      case 'cricket':
        return AppAssets.batIcon;
      default:
        return AppAssets.footBallIcon;
    }
  }

  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  void setDate(DateTime date) {
    selectedDate = date;
    dateController.text =
        '${date.day}/${_getMonthName(date.month)}/${date.year}';
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
    final effectiveDistance = distanceEnabled ? distance : kMaxFilterDistanceKm;
    return FilterData(
      sportIndex: selectedSportIndex,
      sportName: selectedSportIndex != null &&
              selectedSportIndex! >= 0 &&
              selectedSportIndex! < sports.length
          ? sports[selectedSportIndex!].name
          : null,
      skillLevel: selectedSkillIndex != null &&
              selectedSkillIndex! >= 0 &&
              selectedSkillIndex! < skillLevels.length
          ? skillLevels[selectedSkillIndex!]
          : null,
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
