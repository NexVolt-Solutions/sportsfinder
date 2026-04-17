import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/UpdateMatch/update_match_repo.dart';
import 'package:sport_finding/Data/model/UpdateMatch/update_match_model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';

class EditMatchViewModel extends ChangeNotifier {
  final UpdateMatchRepo _updateRepo = UpdateMatchRepo();

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

  UpdateMatchModel? updatedMatch;
  String? error;
  bool isLoading = false;
  String? matchId;

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

  void populateForEdit(UpdateMatchModel match, BuildContext context) {
    matchId = match.id;

    matchTitleController.text = match.title ?? '';
    descriptionController.text = match.description ?? '';
    locationController.text = match.location ?? '';
    maxPlayersController.text = match.maxPlayers?.toString() ?? '';
    selectedSportType = match.sport;
    selectedSkillLevel = match.skillLevel;

    duration = match.durationMinutes ?? 60;
    matchDurationController.text = '$duration minutes';

    if (match.scheduledAt != null && match.scheduledAt!.isNotEmpty) {
      final dt = DateTime.parse(match.scheduledAt!).toLocal();
      _selectedDate = dt;
      _selectedTime = TimeOfDay.fromDateTime(dt);
      dateController.text =
          '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
      timeController.text = TimeOfDay.fromDateTime(dt).format(context);
    }

    notifyListeners();
  }

  void populateForEditFromDiscoveryMatch(
    DiscoveryMatch match,
    BuildContext context,
  ) {
    matchId = match.id;

    matchTitleController.text = match.title;
    descriptionController.text = match.matchDescription;
    locationController.text = match.location;
    maxPlayersController.text = match.participantsTotal.toString();
    selectedSportType = match.sportType;
    selectedSkillLevel = match.skillLevel;
    matchDurationController.text = '$duration minutes';

    debugPrint('📋 [EditMatchViewModel] Populated from DiscoveryMatch:');
    debugPrint('📋 Title: ${match.title}');
    debugPrint(
      '📋 Sport: ${match.sportType} (selected as: $selectedSportType)',
    );
    debugPrint('📋 Skill Level: ${match.skillLevel}');
    debugPrint('📋 Location: ${match.location}');

    final dt = match.matchScheduledStart;
    if (dt != null) {
      _selectedDate = dt;
      _selectedTime = TimeOfDay.fromDateTime(dt);
      dateController.text =
          '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
      timeController.text = TimeOfDay.fromDateTime(dt).format(context);
    } else {
      dateController.text = match.date;
      timeController.text = match.time;
    }

    notifyListeners();
  }

  void setSportType(String? value) {
    debugPrint('🎾 [EditMatchViewModel] setSportType called with: $value');
    selectedSportType = value;
    debugPrint(
      '🎾 [EditMatchViewModel] selectedSportType now = $selectedSportType',
    );
    notifyListeners();
  }

  void setSkillLevel(String? value) {
    selectedSkillLevel = value;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    dateController.text =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void setTime(TimeOfDay time, BuildContext context) {
    _selectedTime = time;
    timeController.text = time.format(context);
  }

  void setDuration(int minutes) {
    duration = minutes;
    matchDurationController.text = '$minutes minutes';
  }

  String? _buildScheduledAt() {
    if (_selectedDate == null || _selectedTime == null) {
      return null;
    }

    final dt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    return dt.toUtc().toIso8601String();
  }

  Future<bool> saveChanges() async {
    if (!formKey.currentState!.validate()) {
      error = 'Please fill all required fields correctly';
      notifyListeners();
      return false;
    }

    if (matchId == null || matchId!.isEmpty) {
      error = 'Match ID is missing';
      notifyListeners();
      return false;
    }

    error = null;
    isLoading = true;
    notifyListeners();

    try {
      final data = {
        'title': matchTitleController.text.trim(),
        'description': descriptionController.text.trim(),
        'sport': selectedSportType,
        'skill_level': selectedSkillLevel,
        'scheduled_at': _buildScheduledAt(),
        'duration_minutes': duration,
        'location': locationController.text.trim(),
        'max_players': int.tryParse(maxPlayersController.text.trim()) ?? 0,
      };

      debugPrint('💾 [EditMatchViewModel] Saving match with data:');
      debugPrint('💾 Title: ${data['title']}');
      debugPrint(
        '💾 Sport: ${data['sport']} (selectedSportType = $selectedSportType)',
      );
      debugPrint('💾 Skill Level: ${data['skill_level']}');
      debugPrint('💾 Location: ${data['location']}');
      debugPrint('💾 Max Players: ${data['max_players']}');
      debugPrint('💾 Duration: ${data['duration_minutes']}');

      updatedMatch = await _updateRepo.updateMatch(
        matchId: matchId!,
        data: data,
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ API Error updating match: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      error = e.toString();
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
