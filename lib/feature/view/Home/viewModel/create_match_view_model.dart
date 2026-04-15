import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/create_match_repo.dart';
import 'package:sport_finding/Data/model/create_match_request_model.dart';

class CreateMatchViewModel extends ChangeNotifier {
  final CreateMatchRepo _repo = CreateMatchRepo();

  final formKey = GlobalKey<FormState>();

  final matchTitleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final locationController = TextEditingController();
  final matchDurationController = TextEditingController();
  final maxPlayersController = TextEditingController();

  String? selectedSportType;
  String? selectedSkillLevel;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int duration = 60;

  MatchModel? createdMatch;
  String? error;
  bool isLoading = false;

  final List<String> sportTypes = [
    'Football',
    'Basketball',
    'Tennis',
    'Cricket',
    'Volleyball',
    'Badminton',
  ];

  final List<String> skillLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  final List<int> durationOptions = [30, 45, 60, 90, 120, 150, 180];

  void setSportType(String? value) {
    selectedSportType = value;
    print("🟢 Selected Sport Type: $value");
    notifyListeners();
  }

  void setSkillLevel(String? value) {
    selectedSkillLevel = value;
    print("🟢 Selected Skill Level: $value");
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    dateController.text =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    print("📅 Selected Date: ${dateController.text}");
    notifyListeners();
  }

  void setTime(TimeOfDay time, BuildContext context) {
    _selectedTime = time;
    timeController.text = time.format(context);

    print("⏰ Selected Time: ${timeController.text}");
    notifyListeners();
  }

  void setDuration(int minutes) {
    duration = minutes;
    matchDurationController.text = '$minutes minutes';

    print("⏳ Selected Duration: $minutes minutes");
    notifyListeners();
  }

  String? _buildScheduledAt() {
    if (_selectedDate == null || _selectedTime == null) {
      print("⚠️ ScheduledAt is NULL (date/time missing)");
      return null;
    }

    final dt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final iso = dt.toUtc().toIso8601String();
    print("📡 ScheduledAt (UTC ISO): $iso");
    return iso;
  }

  Future<bool> createMatchApi() async {
    if (!formKey.currentState!.validate()) {
      print("❌ Form validation failed");
      return false;
    }

    error = null;
    isLoading = true;
    notifyListeners();

    print("🚀 Creating Match API Called");

    try {
      final data = MatchModel(
        id: '',
        title: matchTitleController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        sport: selectedSportType ?? '',
        skillLevel: selectedSkillLevel ?? '',
        status: '',
        scheduledAt: _buildScheduledAt(),
        scheduledDate:
            dateController.text.isEmpty ? null : dateController.text,
        scheduledTime:
            timeController.text.isEmpty ? null : timeController.text,
        durationMinutes: duration,
        location: locationController.text.trim().isEmpty
            ? null
            : locationController.text.trim(),
        maxPlayers:
            int.tryParse(maxPlayersController.text.trim()) ?? 0,
      ).toJson();

      /// 📤 Request Log
      print("========== REQUEST DATA ==========");
      print(data);

      createdMatch = await _repo.createMatch(data);

      /// 📥 Response Log
      print("========== MATCH CREATED SUCCESS ==========");
      print("Match ID: ${createdMatch?.id}");
      print("Match Title: ${createdMatch?.title}");
      print("Full Response Object: $createdMatch");

      return true;
    } catch (e, stackTrace) {
      error = e.toString();

      print("========== ERROR CREATING MATCH ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");

      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    print("🧹 Disposing CreateMatchViewModel");

    matchTitleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    timeController.dispose();
    locationController.dispose();
    matchDurationController.dispose();
    maxPlayersController.dispose();

    super.dispose();
  }
}