// // import 'package:flutter/material.dart';
// // import 'package:sport_finding/Data/Repositories/create_match_repo.dart';
// // import 'package:sport_finding/Data/model/create_match_request_model.dart';

// // class CreateMatchViewModel extends ChangeNotifier {
// //   final CreateMatchRepo _repo = CreateMatchRepo();

// //   final formKey = GlobalKey<FormState>();

// //   final matchTitleController = TextEditingController();
// //   final descriptionController = TextEditingController();
// //   final dateController = TextEditingController();
// //   final timeController = TextEditingController();
// //   final locationController = TextEditingController();
// //   final matchDurationController = TextEditingController();
// //   final maxPlayersController = TextEditingController();

// //   String? selectedSportType;
// //   String? selectedSkillLevel;

// //   DateTime? _selectedDate;
// //   TimeOfDay? _selectedTime;
// //   int duration = 60;

// //   MatchModel? createdMatch;
// //   String? error;
// //   bool isLoading = false;

// //   final List<String> sportTypes = [
// //     'Football',
// //     'Basketball',
// //     'Tennis',
// //     'Cricket',
// //     'Volleyball',
// //     'Badminton',
// //   ];

// //   final List<String> skillLevels = ['Beginner', 'Intermediate', 'Advanced'];

// //   final List<int> durationOptions = [30, 45, 60, 90, 120, 150, 180];

// //   void setSportType(String? value) {
// //     selectedSportType = value;
// //     print("🟢 Selected Sport Type: $value");
// //     notifyListeners();
// //   }

// //   void setSkillLevel(String? value) {
// //     selectedSkillLevel = value;
// //     print("🟢 Selected Skill Level: $value");
// //     notifyListeners();
// //   }

// //   void setDate(DateTime date) {
// //     _selectedDate = date;
// //     dateController.text =
// //         '${date.day.toString().padLeft(2, '0')}/'
// //         '${date.month.toString().padLeft(2, '0')}/'
// //         '${date.year}';

// //     print("📅 Selected Date: ${dateController.text}");
// //     notifyListeners();
// //   }

// //   void setTime(TimeOfDay time, BuildContext context) {
// //     _selectedTime = time;
// //     timeController.text = time.format(context);

// //     print("⏰ Selected Time: ${timeController.text}");
// //     notifyListeners();
// //   }

// //   void setDuration(int minutes) {
// //     duration = minutes;
// //     matchDurationController.text = '$minutes minutes';

// //     print("⏳ Selected Duration: $minutes minutes");
// //     notifyListeners();
// //   }

// //   String? _buildScheduledAt() {
// //     if (_selectedDate == null || _selectedTime == null) {
// //       print("⚠️ ScheduledAt is NULL (date/time missing)");
// //       return null;
// //     }

// //     final dt = DateTime(
// //       _selectedDate!.year,
// //       _selectedDate!.month,
// //       _selectedDate!.day,
// //       _selectedTime!.hour,
// //       _selectedTime!.minute,
// //     );

// //     final iso = dt.toUtc().toIso8601String();
// //     print("📡 ScheduledAt (UTC ISO): $iso");
// //     return iso;
// //   }

// //   Future<bool> createMatchApi() async {
// //     if (!formKey.currentState!.validate()) {
// //       print("❌ Form validation failed");
// //       return false;
// //     }

// //     error = null;
// //     isLoading = true;
// //     notifyListeners();

// //     print("🚀 Creating Match API Called");

// //     try {
// //       final data = MatchModel(
// //         id: '',
// //         title: matchTitleController.text.trim(),
// //         description: descriptionController.text.trim().isEmpty
// //             ? null
// //             : descriptionController.text.trim(),
// //         sport: selectedSportType ?? '',
// //         skillLevel: selectedSkillLevel ?? '',
// //         status: '',
// //         scheduledAt: _buildScheduledAt(),
// //         scheduledDate: dateController.text.isEmpty ? null : dateController.text,
// //         scheduledTime: timeController.text.isEmpty ? null : timeController.text,
// //         durationMinutes: duration,
// //         location: locationController.text.trim().isEmpty
// //             ? null
// //             : locationController.text.trim(),
// //         maxPlayers: int.tryParse(maxPlayersController.text.trim()) ?? 0,
// //       ).toJson();

// //       /// 📤 Request Log
// //       print("========== REQUEST DATA ==========");
// //       print(data);

// //       createdMatch = await _repo.createMatch(data);

// //       /// 📥 Response Log
// //       print("========== MATCH CREATED SUCCESS ==========");
// //       print("Match ID: ${createdMatch?.id}");
// //       print("Match Title: ${createdMatch?.title}");
// //       print("Full Response Object: $createdMatch");

// //       return true;
// //     } catch (e, stackTrace) {
// //       error = e.toString();

// //       print("========== ERROR CREATING MATCH ==========");
// //       print("Error: $e");
// //       print("StackTrace: $stackTrace");

// //       return false;
// //     } finally {
// //       isLoading = false;
// //       notifyListeners();
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     print("🧹 Disposing CreateMatchViewModel");

// //     matchTitleController.dispose();
// //     descriptionController.dispose();
// //     dateController.dispose();
// //     timeController.dispose();
// //     matchDurationController.dispose();
// //     maxPlayersController.dispose();
// //     locationController.dispose();

// //     super.dispose();
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:sport_finding/Data/Repositories/create_match_repo.dart';
// import 'package:sport_finding/Data/Repositories/update_match_repo.dart';
// import 'package:sport_finding/Data/model/create_match_request_model.dart';
// import 'package:sport_finding/Data/model/update_match_model.dart';

// class CreateMatchViewModel extends ChangeNotifier {
//   bool isEditMode = false;
//   String? editingMatchId;

//   void populateForEdit(UpdateMatchModel match) {
//     debugPrint("✏️ Populating data for edit mode");

//     isEditMode = true;
//     editingMatchId = match.id;

//     matchTitleController.text = match.title ?? '';
//     descriptionController.text = match.description ?? '';
//     locationController.text = match.location ?? '';
//     maxPlayersController.text = match.maxPlayers?.toString() ?? '';

//     selectedSportType = match.sport;
//     selectedSkillLevel = match.skillLevel;

//     duration = match.durationMinutes ?? 60;
//     matchDurationController.text = "$duration minutes";

//     /// Parse scheduled date and time
//     if (match.scheduledAt != null) {
//       final dateTime = DateTime.parse(match.scheduledAt!).toLocal();
//       _selectedDate = dateTime;
//       _selectedTime = TimeOfDay.fromDateTime(dateTime);

//       dateController.text =
//           '${dateTime.day.toString().padLeft(2, '0')}/'
//           '${dateTime.month.toString().padLeft(2, '0')}/'
//           '${dateTime.year}';

//       timeController.text =
//           '${_selectedTime!.hourOfPeriod.toString().padLeft(2, '0')}:'
//           '${_selectedTime!.minute.toString().padLeft(2, '0')} '
//           '${_selectedTime!.period == DayPeriod.am ? 'AM' : 'PM'}';
//     }

//     notifyListeners();
//   }

//   final CreateMatchRepo _createRepo = CreateMatchRepo();
//   final UpdateMatchRepo _updateRepo = UpdateMatchRepo();

//   final formKey = GlobalKey<FormState>();

//   // Controllers
//   final matchTitleController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final dateController = TextEditingController();
//   final timeController = TextEditingController();
//   final locationController = TextEditingController();
//   final matchDurationController = TextEditingController();
//   final maxPlayersController = TextEditingController();

//   // Dropdown selections
//   String? selectedSportType;
//   String? selectedSkillLevel;

//   // Internal state
//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;
//   int duration = 60;

//   // API state
//   MatchModel? createdMatch;
//   UpdateMatchModel? updatedMatch;
//   String? error;
//   bool isLoading = false;

//   // Edit mode
//   bool isEditMode = false;
//   String? matchId;

//   // Dropdown data
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

//   // ================================
//   // Setters with Debug Prints
//   // ================================

//   void setSportType(String? value) {
//     selectedSportType = value;
//     print("🟢 Selected Sport Type: $value");
//     notifyListeners();
//   }

//   void setSkillLevel(String? value) {
//     selectedSkillLevel = value;
//     print("🟢 Selected Skill Level: $value");
//     notifyListeners();
//   }

//   void setDate(DateTime date) {
//     _selectedDate = date;
//     dateController.text =
//         '${date.day.toString().padLeft(2, '0')}/'
//         '${date.month.toString().padLeft(2, '0')}/'
//         '${date.year}';

//     print("📅 Selected Date: ${dateController.text}");
//     notifyListeners();
//   }

//   void setTime(TimeOfDay time, BuildContext context) {
//     _selectedTime = time;
//     timeController.text = time.format(context);

//     print("⏰ Selected Time: ${timeController.text}");
//     notifyListeners();
//   }

//   void setDuration(int minutes) {
//     duration = minutes;
//     matchDurationController.text = '$minutes minutes';

//     print("⏳ Selected Duration: $minutes minutes");
//     notifyListeners();
//   }

//   // ================================
//   // Convert Date & Time to ISO
//   // ================================
//   String? _buildScheduledAt() {
//     if (_selectedDate == null || _selectedTime == null) {
//       print("⚠️ ScheduledAt is NULL (date/time missing)");
//       return null;
//     }

//     final dt = DateTime(
//       _selectedDate!.year,
//       _selectedDate!.month,
//       _selectedDate!.day,
//       _selectedTime!.hour,
//       _selectedTime!.minute,
//     );

//     final iso = dt.toUtc().toIso8601String();
//     print("📡 ScheduledAt (UTC ISO): $iso");
//     return iso;
//   }

//   // ================================
//   // Populate Fields for Editing
//   // ================================
//   void populateForEdit(MatchModel match) {
//     print("✏️ Populating fields for Edit Mode...");
//     print("Match ID: ${match.id}");

//     isEditMode = true;
//     matchId = match.id;

//     matchTitleController.text = match.title ?? '';
//     descriptionController.text = match.description ?? '';
//     locationController.text = match.location ?? '';
//     maxPlayersController.text = match.maxPlayers?.toString() ?? '';

//     selectedSportType = match.sport;
//     selectedSkillLevel = match.skillLevel;

//     duration = match.durationMinutes ?? 60;
//     matchDurationController.text = '$duration minutes';

//     if (match.scheduledAt != null) {
//       final dt = DateTime.parse(match.scheduledAt!).toLocal();
//       _selectedDate = dt;
//       _selectedTime = TimeOfDay.fromDateTime(dt);

//       dateController.text =
//           '${dt.day.toString().padLeft(2, '0')}/'
//           '${dt.month.toString().padLeft(2, '0')}/'
//           '${dt.year}';
//     }

//     print("✅ Fields populated successfully.");
//     notifyListeners();
//   }

//   // ================================
//   // Create Match API
//   // ================================
//   Future<bool> createMatchApi() async {
//     if (!formKey.currentState!.validate()) {
//       print("❌ Form validation failed");
//       return false;
//     }

//     error = null;
//     isLoading = true;
//     notifyListeners();

//     print("🚀 Creating Match API Called");

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
//         maxPlayers: int.tryParse(maxPlayersController.text.trim()) ?? 0,
//       ).toJson();

//       print("========== CREATE MATCH REQUEST ==========");
//       print(data);

//       createdMatch = await _createRepo.createMatch(data);

//       print("========== MATCH CREATED SUCCESS ==========");
//       print("Match ID: ${createdMatch?.id}");
//       print("Match Title: ${createdMatch?.title}");
//       print("Full Response: $createdMatch");

//       return true;
//     } catch (e, stackTrace) {
//       error = e.toString();

//       print("========== ERROR CREATING MATCH ==========");
//       print("Error: $e");
//       print("StackTrace: $stackTrace");

//       return false;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   // ================================
//   // Update Match API
//   // ================================
//   Future<bool> updateMatchApi() async {
//     if (!formKey.currentState!.validate()) {
//       print("❌ Form validation failed");
//       return false;
//     }

//     if (matchId == null || matchId!.isEmpty) {
//       error = "Match ID is missing";
//       print("❌ Match ID is missing");
//       return false;
//     }

//     error = null;
//     isLoading = true;
//     notifyListeners();

//     print("🔄 Updating Match API Called");
//     print("Match ID: $matchId");

//     try {
//       final data = {
//         "title": matchTitleController.text.trim(),
//         "description": descriptionController.text.trim(),
//         "sport": selectedSportType,
//         "skill_level": selectedSkillLevel,
//         "scheduled_at": _buildScheduledAt(),
//         "duration_minutes": duration,
//         "location": locationController.text.trim(),
//         "max_players": int.tryParse(maxPlayersController.text.trim()) ?? 0,
//       };

//       print("========== UPDATE MATCH REQUEST ==========");
//       print(data);

//       updatedMatch = await _updateRepo.updateMatch(
//         matchId: matchId!,
//         data: data,
//       );

//       print("========== MATCH UPDATED SUCCESS ==========");
//       print("Updated Match ID: ${updatedMatch?.id}");
//       print("Updated Title: ${updatedMatch?.title}");
//       print("Full Response: $updatedMatch");

//       return true;
//     } catch (e, stackTrace) {
//       error = e.toString();

//       print("========== ERROR UPDATING MATCH ==========");
//       print("Error: $e");
//       print("StackTrace: $stackTrace");

//       return false;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   // ================================
//   // Submit Method (Create or Update)
//   // ================================
//   Future<bool> submitMatch() async {
//     print(
//       isEditMode
//           ? "📤 Submitting Updated Match..."
//           : "📤 Submitting New Match...",
//     );

//     return isEditMode ? await updateMatchApi() : await createMatchApi();
//   }

//   // ================================
//   // Dispose Controllers
//   // ================================
//   @override
//   void dispose() {
//     print("🧹 Disposing CreateMatchViewModel");

//     matchTitleController.dispose();
//     descriptionController.dispose();
//     dateController.dispose();
//     timeController.dispose();
//     locationController.dispose();
//     matchDurationController.dispose();
//     maxPlayersController.dispose();

//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/create_match_repo.dart';
import 'package:sport_finding/Data/Repositories/update_match_repo.dart';
import 'package:sport_finding/Data/model/create_match_request_model.dart';
import 'package:sport_finding/Data/model/UpdateMatch/update_match_model.dart';

class CreateMatchViewModel extends ChangeNotifier {
  final CreateMatchRepo _createRepo = CreateMatchRepo();
  final UpdateMatchRepo _updateRepo = UpdateMatchRepo();

  final formKey = GlobalKey<FormState>();

  // Controllers
  final matchTitleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final locationController = TextEditingController();
  final matchDurationController = TextEditingController();
  final maxPlayersController = TextEditingController();

  // Dropdown selections
  String? selectedSportType;
  String? selectedSkillLevel;

  // Internal state
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int duration = 60;

  // API state
  MatchModel? createdMatch;
  UpdateMatchModel? updatedMatch;
  String? error;
  bool isLoading = false;

  // Edit mode state
  bool isEditMode = false;
  String? matchId;

  // Dropdown data
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

  // ================================
  // Populate Fields for Editing
  // ================================
  void populateForEdit(UpdateMatchModel match, dynamic navigatorKey) {
    debugPrint("✏️ Populating fields for Edit Mode...");
    debugPrint("Match ID: ${match.id}");

    isEditMode = true;
    matchId = match.id;

    matchTitleController.text = match.title ?? '';
    descriptionController.text = match.description ?? '';
    locationController.text = match.location ?? '';
    maxPlayersController.text = match.maxPlayers?.toString() ?? '';

    selectedSportType = match.sport;
    selectedSkillLevel = match.skillLevel;

    duration = match.durationMinutes ?? 60;
    matchDurationController.text = "$duration minutes";

    if (match.scheduledAt != null) {
      final dt = DateTime.parse(match.scheduledAt!).toLocal();
      _selectedDate = dt;
      _selectedTime = TimeOfDay.fromDateTime(dt);

      dateController.text =
          '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';

      timeController.text = TimeOfDay.fromDateTime(
        dt,
      ).format(navigatorKey.currentContext!);
    }

    notifyListeners();
  }

  // ================================
  // Setters
  // ================================
  void setSportType(String? value) {
    selectedSportType = value;
    debugPrint("🟢 Selected Sport Type: $value");
    notifyListeners();
  }

  void setSkillLevel(String? value) {
    selectedSkillLevel = value;
    debugPrint("🟢 Selected Skill Level: $value");
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    dateController.text =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
    debugPrint("📅 Selected Date: ${dateController.text}");
    // No notifyListeners — [dateController] drives the field; avoids rebuilding
    // the whole create-match form (and jank with the keyboard).
  }

  void setTime(TimeOfDay time, BuildContext context) {
    _selectedTime = time;
    timeController.text = time.format(context);
    debugPrint("⏰ Selected Time: ${timeController.text}");
  }

  void setDuration(int minutes) {
    duration = minutes;
    matchDurationController.text = '$minutes minutes';
    debugPrint("⏳ Selected Duration: $minutes minutes");
  }

  // ================================
  // Convert Date & Time to ISO
  // ================================
  String? _buildScheduledAt() {
    if (_selectedDate == null || _selectedTime == null) {
      debugPrint("⚠️ ScheduledAt is NULL");
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
    debugPrint("📡 ScheduledAt: $iso");
    return iso;
  }

  // ================================
  // Create Match API
  // ================================
  Future<bool> createMatchApi() async {
    if (!formKey.currentState!.validate()) return false;

    isLoading = true;
    notifyListeners();

    try {
      final data = MatchModel(
        id: '',
        title: matchTitleController.text.trim(),
        description: descriptionController.text.trim(),
        sport: selectedSportType ?? '',
        skillLevel: selectedSkillLevel ?? '',
        status: '',
        scheduledAt: _buildScheduledAt(),
        scheduledDate: dateController.text,
        scheduledTime: timeController.text,
        durationMinutes: duration,
        location: locationController.text.trim(),
        maxPlayers: int.tryParse(maxPlayersController.text.trim()) ?? 0,
      ).toJson();

      debugPrint("📤 CREATE REQUEST: $data");

      createdMatch = await _createRepo.createMatch(data);

      debugPrint("✅ Match Created: ${createdMatch?.id}");
      return true;
    } catch (e) {
      error = e.toString();
      debugPrint("❌ Create Error: $error");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================================
  // Update Match API
  // ================================
  Future<bool> updateMatchApi() async {
    if (!formKey.currentState!.validate()) return false;

    if (matchId == null) {
      error = "Match ID is missing";
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final data = {
        "title": matchTitleController.text.trim(),
        "description": descriptionController.text.trim(),
        "sport": selectedSportType,
        "skill_level": selectedSkillLevel,
        "scheduled_at": _buildScheduledAt(),
        "duration_minutes": duration,
        "location": locationController.text.trim(),
        "max_players": int.tryParse(maxPlayersController.text.trim()) ?? 0,
      };

      debugPrint("📤 UPDATE REQUEST: $data");

      updatedMatch = await _updateRepo.updateMatch(
        matchId: matchId!,
        data: data,
      );

      debugPrint("✅ Match Updated: ${updatedMatch?.id}");
      return true;
    } catch (e) {
      error = e.toString();
      debugPrint("❌ Update Error: $error");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================================
  // Submit (Create or Update)
  // ================================
  Future<bool> submitMatch() async {
    return isEditMode ? updateMatchApi() : createMatchApi();
  }

  @override
  void dispose() {
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
