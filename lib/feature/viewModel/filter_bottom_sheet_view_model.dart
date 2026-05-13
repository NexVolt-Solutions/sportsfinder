import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Network/platform_options_store.dart';
import 'package:sport_finding/Data/model/match_filters.dart';

 
class FilterBottomSheetViewModel extends ChangeNotifier {
  FilterBottomSheetViewModel({FilterData? initial}) : _initial = initial {
    _load();
  }

  final FilterData? _initial;
  bool _appliedInitial = false;

  int? selectedSportIndex;
  int? selectedSkillIndex;
  double distance = kMaxFilterDistanceKm;
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
      _applyInitialIfNeeded();
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
    debugPrint(
      '🧰 [FilterVM] toggleSport index=$index selectedSportIndex=$selectedSportIndex',
    );
    notifyListeners();
  }

  void toggleSkill(int index) {
    selectedSkillIndex = selectedSkillIndex == index ? null : index;
    debugPrint(
      '🧰 [FilterVM] toggleSkill index=$index selectedSkillIndex=$selectedSkillIndex',
    );
    notifyListeners();
  }

  void setDistance(double v) {
    distance = v;
    distanceEnabled = true;
    debugPrint(
      '🧰 [FilterVM] setDistance distance=$distance enabled=$distanceEnabled',
    );
    notifyListeners();
  }

  void reset() {
    selectedSportIndex = null;
    selectedSkillIndex = null;
    distance = kMaxFilterDistanceKm;
    distanceEnabled = false;
    selectedDate = null;
    selectedTime = null;
    dateController.clear();
    timeController.clear();
    notifyListeners();
  }

  FilterData buildFilterData() {
    final effectiveDistance = distanceEnabled ? distance : kMaxFilterDistanceKm;
    final data = FilterData(
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
    debugPrint('🧰 [FilterVM] buildFilterData → $data');
    return data;
  }

  void _applyInitialIfNeeded() {
    if (_appliedInitial) return;
    final initial = _initial;
    if (initial == null) return;

    // sport
    final initialSportName = initial.sportName?.trim();
    if (initial.sportIndex != null &&
        initial.sportIndex! >= 0 &&
        initial.sportIndex! < sports.length) {
      selectedSportIndex = initial.sportIndex;
    } else if (initialSportName != null && initialSportName.isNotEmpty) {
      final idx = sports.indexWhere(
        (s) => s.name.toLowerCase() == initialSportName.toLowerCase(),
      );
      if (idx >= 0) selectedSportIndex = idx;
    }

    // skill
    final initialSkill = initial.skillLevel?.trim();
    if (initialSkill != null && initialSkill.isNotEmpty) {
      final idx = skillLevels.indexWhere(
        (s) => s.toLowerCase() == initialSkill.toLowerCase(),
      );
      if (idx >= 0) selectedSkillIndex = idx;
    }

    // distance
    final d = initial.distance;
    if (d >= kMaxFilterDistanceKm - 0.5) {
      distanceEnabled = false;
      distance = kMaxFilterDistanceKm;
    } else {
      distanceEnabled = true;
      distance = d.clamp(0, kMaxFilterDistanceKm);
    }

    // date/time
    selectedDate = initial.date;
    selectedTime = initial.time;
    if (selectedDate != null) {
      final date = selectedDate!;
      dateController.text =
          '${date.day}/${_getMonthName(date.month)}/${date.year}';
    }
    if (selectedTime != null) {
      timeController.text = _formatAmPm(selectedTime!);
    }

    _appliedInitial = true;
    debugPrint('🧰 [FilterVM] applied initial → ${buildFilterData()}');
    notifyListeners();
  }

  String _formatAmPm(TimeOfDay t) {
    final m = t.minute.toString().padLeft(2, '0');
    final isPm = t.hour >= 12;
    var h12 = t.hour % 12;
    if (h12 == 0) h12 = 12;
    return '$h12:$m ${isPm ? 'PM' : 'AM'}';
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
