// import 'package:flutter/material.dart';
// import 'package:sport_finding/Data/Repositories/create_match_repo.dart';
// import 'package:sport_finding/Data/model/create_match_request_model.dart';

// class CreateMatchViewModel extends ChangeNotifier {
//   final MatchRepository _repo = MatchRepository();

//   final formKey = GlobalKey<FormState>();

//   final matchTitleController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final dateController = TextEditingController();
//   final timeController = TextEditingController();
//   final locationController = TextEditingController();
//   final matchDurationController = TextEditingController();

//   String? selectedSportType;
//   String? selectedSkillLevel;

//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;
//   int duration = 60;

//   MatchModel? createdMatch;
//   String? error;
//   bool isLoading = false;

//   final List<String> sportTypes = [
//     'Football',
//     'Basketball',
//     'Tennis',
//     'Cricket',
//     'Volleyball',
//     'Badminton',
//   ];

//   final List<String> skillLevels = ['Beginner', 'Intermediate', 'Advanced'];

//   final List<int> durationOptions = [30, 45, 60, 90, 120, 150, 180];

//   void setSportType(String? value) {
//     selectedSportType = value;
//     notifyListeners();
//   }

//   void setSkillLevel(String? value) {
//     selectedSkillLevel = value;
//     notifyListeners();
//   }

//   void setDate(DateTime date) {
//     _selectedDate = date;
//     dateController.text =
//         '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//     notifyListeners();
//   }

//   void setTime(TimeOfDay time, BuildContext context) {
//     _selectedTime = time;
//     timeController.text = time.format(context);
//     notifyListeners();
//   }

//   void setDuration(int minutes) {
//     duration = minutes;
//     matchDurationController.text = '$minutes minutes';
//     notifyListeners();
//   }

//   String? _buildScheduledAt() {
//     if (_selectedDate == null || _selectedTime == null) return null;
//     final dt = DateTime(
//       _selectedDate!.year,
//       _selectedDate!.month,
//       _selectedDate!.day,
//       _selectedTime!.hour,
//       _selectedTime!.minute,
//     );
//     return dt.toUtc().toIso8601String();
//   }

//   Future<bool> createMatchApi() async {
//     error = null;
//     isLoading = true;
//     notifyListeners();

//     try {
//       final data = MatchModel(
//         id: '',
//         title: matchTitleController.text.trim(),
//         description: descriptionController.text.trim().isEmpty
//             ? null
//             : descriptionController.text.trim(),
//         sport: selectedSportType ?? '',
//         skillLevel: selectedSkillLevel ?? '',
//         status: '',
//         scheduledAt: _buildScheduledAt(),
//         scheduledDate: dateController.text.isEmpty ? null : dateController.text,
//         scheduledTime: timeController.text.isEmpty ? null : timeController.text,
//         durationMinutes: duration,
//         location: locationController.text.trim().isEmpty
//             ? null
//             : locationController.text.trim(),
//       ).toJson();

//       createdMatch = await _repo.createMatch(data);
//       return true;
//     } catch (e) {
//       error = e.toString();
//       return false;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   @override
//   void dispose() {
//     matchTitleController.dispose();
//     descriptionController.dispose();
//     dateController.dispose();
//     timeController.dispose();
//     locationController.dispose();
//     matchDurationController.dispose();
//     super.dispose();
//   }
// }
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sport_finding/Data/Repositories/create_match_repo.dart';
import 'package:sport_finding/Data/model/create_match_request_model.dart';

class CreateMatchViewModel extends ChangeNotifier {
  final MatchRepository _repo = MatchRepository();

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

  final List<String> skillLevels = ['Beginner', 'Intermediate', 'Advanced'];

  final List<int> durationOptions = [30, 45, 60, 90, 120, 150, 180];

  /// 📌 Helper Method for Logging
  void _log(String message) {
    if (kDebugMode) {
      log(message, name: 'CreateMatchViewModel');
    }
  }

  void setSportType(String? value) {
    selectedSportType = value;
    _log('Selected Sport Type: $value');
    notifyListeners();
  }

  void setSkillLevel(String? value) {
    selectedSkillLevel = value;
    _log('Selected Skill Level: $value');
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    dateController.text =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
    _log('Selected Date: ${dateController.text}');
    notifyListeners();
  }

  void setTime(TimeOfDay time, BuildContext context) {
    _selectedTime = time;
    timeController.text = time.format(context);
    _log('Selected Time: ${timeController.text}');
    notifyListeners();
  }

  void setDuration(int minutes) {
    duration = minutes;
    matchDurationController.text = '$minutes minutes';
    _log('Selected Duration: $minutes minutes');
    notifyListeners();
  }

  /// 📅 Builds ISO 8601 UTC DateTime
  String? _buildScheduledAt() {
    if (_selectedDate == null || _selectedTime == null) {
      _log('ScheduledAt is null: Date or Time not selected');
      return null;
    }

    final dt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final isoDate = dt.toUtc().toIso8601String();
    _log('ScheduledAt (UTC ISO): $isoDate');
    return isoDate;
  }

  /// 🚀 Create Match API
  Future<bool> createMatchApi() async {
    if (!formKey.currentState!.validate()) {
      _log('Form validation failed');
      return false;
    }

    error = null;
    isLoading = true;
    notifyListeners();

    _log('Creating match...');

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
        scheduledDate: dateController.text.isEmpty ? null : dateController.text,
        scheduledTime: timeController.text.isEmpty ? null : timeController.text,
        durationMinutes: duration,
        location: locationController.text.trim().isEmpty
            ? null
            : locationController.text.trim(),
        maxPlayers: int.tryParse(maxPlayersController.text.trim()) ?? 0,
      ).toJson();

      /// 📤 Log Request Payload
      _log('Request Payload: $data');

      createdMatch = await _repo.createMatch(data);

      /// 📥 Log Response
      _log('Match Created Successfully!');
      _log('Match ID: ${createdMatch?.id}');
      _log('Match Title: ${createdMatch?.title}');

      return true;
    } catch (e, stackTrace) {
      error = e.toString();

      /// ❌ Log Error
      log(
        'Error Creating Match: $error',
        name: 'CreateMatchViewModel',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );

      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _log('Disposing CreateMatchViewModel controllers');

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
