import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/create_match_repository.dart';
import 'package:sport_finding/Data/model/app_user.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';

class CreateMatchScreenViewModel extends ChangeNotifier {
  final CreateMatchRepository repository;
  CreateMatchScreenViewModel({required this.repository}) {
    selectedSportType = sportTypes.first;
    selectedSkillLevel = skillLevels[1];
    matchDurationController.text = '$_duration minutes';
    maxPlayersController.text = _maxPlayers.toString();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> createMatchApi(String token) async {
    try {
      _isLoading = true;
      notifyListeners();
      if (!validateForCreate()) return false;

      final date = selectedDate!;
      final time = selectedTime!;

      final scheduledAt =
          "${date.toIso8601String().split('T')[0]}T${time.hour}:${time.minute}:00";

      final response = await repository.createMatch(
        title: matchTitleController.text.trim(),
        description: descriptionController.text.trim(),
        sport: selectedSportType!,
        facilityAddress: locationController.text.trim(),
        scheduledAt: scheduledAt,
        durationMinutes: _duration,
        maxPlayers: _maxPlayers,
        skillLevel: selectedSkillLevel!,
        token: token,
      );
      print("✅ Match Created: $response");
      return true;
    } catch (e) {
      print("Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  final formKey = GlobalKey<FormState>();

  // 🔤 Controllers (ONLY for text fields)
  final TextEditingController matchTitleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController matchDurationController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController maxPlayersController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // 🔽 Dropdown Values
  String? selectedSkillLevel;
  String? selectedSportType;

  // 📊 Data
  int _duration = 90;
  int get duration => _duration;

  final List<int> durationOptions = List<int>.generate(
    12, // 15..180 (15 * 12)
    (i) => 15 * (i + 1),
  );

  int _maxPlayers = 10;
  int get maxPlayers => _maxPlayers;

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  TimeOfDay? _selectedTime;
  TimeOfDay? get selectedTime => _selectedTime;

  // 📋 Lists
  final List<String> skillLevels = ['Beginner', 'Intermediate', 'Advanced'];

  final List<String> sportTypes = [
    'Football',
    'Basketball',
    'Cricket',
    'Tennis',
    'Volleyball',
    'Badminton',
  ];

  // 📅 Date
  void setDate(DateTime date) {
    _selectedDate = date;
    dateController.text =
        '${date.day}/${_getMonthName(date.month)}/${date.year}';
    notifyListeners();
  }

  // ⏰ Time
  void setTime(TimeOfDay time, BuildContext context) {
    _selectedTime = time;
    timeController.text = time.format(context);
    notifyListeners();
  }

  // ⏱ Duration
  void setDuration(int minutes) {
    if (!durationOptions.contains(minutes)) return;
    _duration = minutes;
    matchDurationController.text = '$_duration minutes';
    notifyListeners();
  }

  void incrementDuration() {
    final idx = durationOptions.indexOf(_duration);
    final next = idx < 0 ? durationOptions.first : durationOptions[idx + 1];
    setDuration(next);
  }

  void decrementDuration() {
    final idx = durationOptions.indexOf(_duration);
    if (idx <= 0) {
      setDuration(durationOptions.first);
      return;
    }
    setDuration(durationOptions[idx - 1]);
  }

  // 👥 Players
  void incrementMaxPlayers() {
    _maxPlayers++;
    maxPlayersController.text = _maxPlayers.toString();
    notifyListeners();
  }

  void decrementMaxPlayers() {
    if (_maxPlayers > 2) {
      _maxPlayers--;
      maxPlayersController.text = _maxPlayers.toString();
      notifyListeners();
    }
  }

  // 🔽 Dropdown Setters
  void setSkillLevel(String? level) {
    selectedSkillLevel = level;
    notifyListeners();
  }

  void setSportType(String? sport) {
    selectedSportType = sport;
    notifyListeners();
  }

  /// Returns false if required fields are missing (shows a snackbar from the UI).
  bool validateForCreate() {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (selectedSportType == null || selectedSkillLevel == null) return false;
    if (dateController.text.trim().isEmpty) return false;
    if (timeController.text.trim().isEmpty) return false;
    if (locationController.text.trim().isEmpty) return false;
    return true;
  }

  /// Builds a [DiscoveryMatch] from the current form (call after validation).
  DiscoveryMatch toCreatedDiscoveryMatch() {
    final sport = selectedSportType ?? sportTypes.first;
    final skill = selectedSkillLevel ?? skillLevels[1];
    final loc = locationController.text.trim();
    final desc = descriptionController.text.trim();
    final dateStr = dateController.text.trim();
    final timeStr = timeController.text.trim();
    final title = matchTitleController.text.trim();

    final durationNote = 'Duration: $_duration min.';
    final fullDescription = desc.isEmpty
        ? '$durationNote ${loc.isNotEmpty ? 'At $loc.' : ''}'
        : '$desc\n$durationNote';

    return DiscoveryMatch(
      id: 'created_${DateTime.now().millisecondsSinceEpoch}',
      hostUserId: AppUser.current.id,
      title: title,
      distanceKm: 0,
      sportType: sport,
      location: loc.isEmpty ? 'Location TBD' : loc,
      date: dateStr.isEmpty ? '—' : dateStr,
      time: timeStr.isEmpty ? '—' : timeStr,
      participantsJoined: 1,
      participantsTotal: _maxPlayers.clamp(2, 99),
      players: const ['You'],
      hostDisplayName: 'You',
      skillLevel: skill,
      matchDescription: fullDescription,
      hostBio:
          'You created this match. Invite players from the success screen.',
      playerSkills: const ['Host'],
      hostMatchesPlayed: 1,
    );
  }

  // 📅 Helper
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
    matchTitleController.dispose();
    dateController.dispose();
    timeController.dispose();
    matchDurationController.dispose();
    locationController.dispose();
    maxPlayersController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
