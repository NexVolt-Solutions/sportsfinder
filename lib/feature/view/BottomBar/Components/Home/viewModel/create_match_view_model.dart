// import 'package:flutter/material.dart';
// import 'package:sport_finding/Data/model/create_match_request_model.dart';
// import 'package:sport_finding/Data/model/app_user.dart';
// import 'package:sport_finding/Data/model/discovery_match.dart';

// class CreateMatchScreenViewModel extends ChangeNotifier {
//   final CreateMatchRepository repository;
//   CreateMatchScreenViewModel({required this.repository}) {
//     selectedSportType = sportTypes.first;
//     selectedSkillLevel = skillLevels[1];
//     matchDurationController.text = '$_duration minutes';
//     maxPlayersController.text = _maxPlayers.toString();
//   }

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   Future<bool> createMatchApi(String token) async {
//     try {
//       _isLoading = true;
//       notifyListeners();
//       if (!validateForCreate()) return false;

//       final date = selectedDate!;
//       final time = selectedTime!;

//       final scheduledAt =
//           "${date.toIso8601String().split('T')[0]}T${time.hour}:${time.minute}:00";

//       final response = await repository.createMatch(
//         title: matchTitleController.text.trim(),
//         description: descriptionController.text.trim(),
//         sport: selectedSportType!,
//         facilityAddress: locationController.text.trim(),
//         scheduledAt: scheduledAt,
//         durationMinutes: _duration,
//         maxPlayers: _maxPlayers,
//         skillLevel: selectedSkillLevel!,
//         token: token,
//       );
//       print("✅ Match Created: $response");
//       return true;
//     } catch (e) {
//       print("Error: $e");
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   final formKey = GlobalKey<FormState>();

//   // 🔤 Controllers (ONLY for text fields)
//   final TextEditingController matchTitleController = TextEditingController();
//   final TextEditingController dateController = TextEditingController();
//   final TextEditingController timeController = TextEditingController();
//   final TextEditingController matchDurationController = TextEditingController();
//   final TextEditingController locationController = TextEditingController();
//   final TextEditingController maxPlayersController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();

//   // 🔽 Dropdown Values
//   String? selectedSkillLevel;
//   String? selectedSportType;

//   // 📊 Data
//   int _duration = 90;
//   int get duration => _duration;

//   final List<int> durationOptions = List<int>.generate(
//     12, // 15..180 (15 * 12)
//     (i) => 15 * (i + 1),
//   );

//   int _maxPlayers = 10;
//   int get maxPlayers => _maxPlayers;

//   DateTime? _selectedDate;
//   DateTime? get selectedDate => _selectedDate;

//   TimeOfDay? _selectedTime;
//   TimeOfDay? get selectedTime => _selectedTime;

//   // 📋 Lists
//   final List<String> skillLevels = ['Beginner', 'Intermediate', 'Advanced'];

//   final List<String> sportTypes = [
//     'Football',
//     'Basketball',
//     'Cricket',
//     'Tennis',
//     'Volleyball',
//     'Badminton',
//   ];

//   // 📅 Date
//   void setDate(DateTime date) {
//     _selectedDate = date;
//     dateController.text =
//         '${date.day}/${_getMonthName(date.month)}/${date.year}';
//     notifyListeners();
//   }

//   // ⏰ Time
//   void setTime(TimeOfDay time, BuildContext context) {
//     _selectedTime = time;
//     timeController.text = time.format(context);
//     notifyListeners();
//   }

//   // ⏱ Duration
//   void setDuration(int minutes) {
//     if (!durationOptions.contains(minutes)) return;
//     _duration = minutes;
//     matchDurationController.text = '$_duration minutes';
//     notifyListeners();
//   }

//   void incrementDuration() {
//     final idx = durationOptions.indexOf(_duration);
//     final next = idx < 0 ? durationOptions.first : durationOptions[idx + 1];
//     setDuration(next);
//   }

//   void decrementDuration() {
//     final idx = durationOptions.indexOf(_duration);
//     if (idx <= 0) {
//       setDuration(durationOptions.first);
//       return;
//     }
//     setDuration(durationOptions[idx - 1]);
//   }

//   // 👥 Players
//   void incrementMaxPlayers() {
//     _maxPlayers++;
//     maxPlayersController.text = _maxPlayers.toString();
//     notifyListeners();
//   }

//   void decrementMaxPlayers() {
//     if (_maxPlayers > 2) {
//       _maxPlayers--;
//       maxPlayersController.text = _maxPlayers.toString();
//       notifyListeners();
//     }
//   }

//   // 🔽 Dropdown Setters
//   void setSkillLevel(String? level) {
//     selectedSkillLevel = level;
//     notifyListeners();
//   }

//   void setSportType(String? sport) {
//     selectedSportType = sport;
//     notifyListeners();
//   }

//   /// Returns false if required fields are missing (shows a snackbar from the UI).
//   bool validateForCreate() {
//     if (!(formKey.currentState?.validate() ?? false)) return false;
//     if (selectedSportType == null || selectedSkillLevel == null) return false;
//     if (dateController.text.trim().isEmpty) return false;
//     if (timeController.text.trim().isEmpty) return false;
//     if (locationController.text.trim().isEmpty) return false;
//     return true;
//   }

//   /// Builds a [DiscoveryMatch] from the current form (call after validation).
//   DiscoveryMatch toCreatedDiscoveryMatch() {
//     final sport = selectedSportType ?? sportTypes.first;
//     final skill = selectedSkillLevel ?? skillLevels[1];
//     final loc = locationController.text.trim();
//     final desc = descriptionController.text.trim();
//     final dateStr = dateController.text.trim();
//     final timeStr = timeController.text.trim();
//     final title = matchTitleController.text.trim();

//     final durationNote = 'Duration: $_duration min.';
//     final fullDescription = desc.isEmpty
//         ? '$durationNote ${loc.isNotEmpty ? 'At $loc.' : ''}'
//         : '$desc\n$durationNote';

//     return DiscoveryMatch(
//       id: 'created_${DateTime.now().millisecondsSinceEpoch}',
//       hostUserId: AppUser.current.id,
//       title: title,
//       distanceKm: 0,
//       sportType: sport,
//       location: loc.isEmpty ? 'Location TBD' : loc,
//       date: dateStr.isEmpty ? '—' : dateStr,
//       time: timeStr.isEmpty ? '—' : timeStr,
//       participantsJoined: 1,
//       participantsTotal: _maxPlayers.clamp(2, 99),
//       players: const ['You'],
//       hostDisplayName: 'You',
//       skillLevel: skill,
//       matchDescription: fullDescription,
//       hostBio:
//           'You created this match. Invite players from the success screen.',
//       playerSkills: const ['Host'],
//       hostMatchesPlayed: 1,
//     );
//   }

//   // 📅 Helper
//   String _getMonthName(int month) {
//     const months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];
//     return months[month - 1];
//   }

//   @override
//   void dispose() {
//     matchTitleController.dispose();
//     dateController.dispose();
//     timeController.dispose();
//     matchDurationController.dispose();
//     locationController.dispose();
//     maxPlayersController.dispose();
//     descriptionController.dispose();
//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/create_match_repo.dart';
import 'package:sport_finding/Data/model/create_match_request_model.dart';
import 'package:sport_finding/Data/model/create_match_response_model.dart';

class CreateMatchViewModel extends ChangeNotifier {
  final CreateMatchRepo _repository = CreateMatchRepo();

  final formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController matchTitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController matchDurationController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController maxPlayersController = TextEditingController();

  // Dropdown Data
  final List<String> sportTypes = [
    'Football',
    'Basketball',
    'Cricket',
    'Tennis',
    'Volleyball',
    'Badminton',
  ];

  final List<String> skillLevels = ['Beginner', 'Intermediate', 'Advanced'];

  String? selectedSportType;
  String? selectedSkillLevel;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  int _duration = 90;
  int get duration => _duration;

  final List<int> durationOptions = List.generate(
    12,
    (index) => (index + 1) * 15,
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  CreateMatchResponseModel? _createdMatch;
  CreateMatchResponseModel? get createdMatch => _createdMatch;

  CreateMatchViewModel() {
    selectedSportType = sportTypes.first;
    selectedSkillLevel = skillLevels[1];
    matchDurationController.text = '$_duration minutes';
    maxPlayersController.text = '10';
  }

  /// 📅 Set Date
  void setDate(DateTime date) {
    _selectedDate = date;
    dateController.text = "${date.day}/${date.month}/${date.year}";
    notifyListeners();
  }

  /// ⏰ Set Time
  void setTime(TimeOfDay time, BuildContext context) {
    _selectedTime = time;
    timeController.text = time.format(context);
    notifyListeners();
  }

  /// ⏱ Set Duration
  void setDuration(int minutes) {
    _duration = minutes;
    matchDurationController.text = "$minutes minutes";
    notifyListeners();
  }

  /// 🔽 Set Sport
  void setSportType(String? sport) {
    selectedSportType = sport;
    notifyListeners();
  }

  /// 🔽 Set Skill Level
  void setSkillLevel(String? level) {
    selectedSkillLevel = level;
    notifyListeners();
  }

  /// ✅ Validate Form
  bool validateForm() {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (_selectedDate == null || _selectedTime == null) return false;
    if (selectedSportType == null || selectedSkillLevel == null) {
      return false;
    }
    return true;
  }

  /// 🚀 Create Match API
  Future<bool> createMatchApi() async {
    if (!validateForm()) {
      _error = "Please fill all required fields.";
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final date = _selectedDate!;
      final time = _selectedTime!;

      final scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      final request = CreateMatchRequestModel(
        title: matchTitleController.text.trim(),
        description: descriptionController.text.trim(),
        sport: selectedSportType!,
        facilityAddress: locationController.text.trim(),
        location: locationController.text.trim(),
        locationName: locationController.text.trim(),
        latitude: 0.0, // Replace with actual coordinates
        longitude: 0.0, // Replace with actual coordinates
        scheduledAt: scheduledAt,
        date: date.toIso8601String().split('T')[0],
        time:
            "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
        durationMinutes: _duration,
        maxPlayers: int.tryParse(maxPlayersController.text) ?? 10,
        skillLevel: selectedSkillLevel!,
      );

      _createdMatch = await _repository.createMatch(request);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint("❌ Create Match Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    matchTitleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    timeController.dispose();
    matchDurationController.dispose();
    locationController.dispose();
    maxPlayersController.dispose();
    super.dispose();
  }
}
