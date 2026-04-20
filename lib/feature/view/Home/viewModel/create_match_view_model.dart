import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/UpdateMatch/update_match_repo.dart';
import 'package:sport_finding/Data/Repositories/create_match_repo.dart';
import 'package:sport_finding/Data/model/UpdateMatch/update_match_model.dart';
import 'package:sport_finding/Data/model/create_match_request_model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/utils/logger.dart';

class CreateMatchViewModel extends ChangeNotifier {
  final CreateMatchRepo _createRepo = CreateMatchRepo();
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

  MatchModel? createdMatch;
  UpdateMatchModel? updatedMatch;
  String? error;
  bool isLoading = false;

  bool isEditMode = false;
  String? matchId;

  CreateMatchViewModel() {
    _hydrateSavedLocation();
  }

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
    isEditMode = true;
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
    isEditMode = true;
    matchId = match.id;

    matchTitleController.text = match.title;
    descriptionController.text = match.matchDescription;
    locationController.text = match.location;
    maxPlayersController.text = match.participantsTotal.toString();
    selectedSportType = match.sportType;
    selectedSkillLevel = match.skillLevel;
    matchDurationController.text = '$duration minutes';

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
    selectedSportType = value;
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

  Future<void> _hydrateSavedLocation() async {
    if (locationController.text.trim().isNotEmpty) return;
    final savedLocation = await AppPreferences.getCurrentLocationText();
    if (savedLocation == null || savedLocation.trim().isEmpty) {
      AppLogger.warning(
        'No saved exact location found for create match form.',
        tag: 'CreateMatchVM',
      );
      return;
    }

    locationController.text = savedLocation;
    AppLogger.info(
      'Loaded saved exact location into create match form: $savedLocation',
      tag: 'CreateMatchVM',
    );
    notifyListeners();
  }

  Future<String> _resolveLocationForRequest() async {
    final typedLocation = locationController.text.trim();
    if (typedLocation.isNotEmpty) {
      AppLogger.debug(
        'Using location from form field: $typedLocation',
        tag: 'CreateMatchVM',
      );
      return typedLocation;
    }

    final savedLocation = await AppPreferences.getCurrentLocationText();
    if (savedLocation != null && savedLocation.trim().isNotEmpty) {
      locationController.text = savedLocation;
      AppLogger.info(
        'Location field was empty, using saved exact location: $savedLocation',
        tag: 'CreateMatchVM',
      );
      return savedLocation;
    }

    AppLogger.warning(
      'Create match request still has no location available.',
      tag: 'CreateMatchVM',
    );
    return '';
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

  Future<bool> createMatchApi() async {
    if (!formKey.currentState!.validate()) return false;

    error = null;
    isLoading = true;
    notifyListeners();

    try {
      final resolvedLocation = await _resolveLocationForRequest();
      if (resolvedLocation.isEmpty) {
        error =
            'Location is required. Please allow location access or enter a location.';
        AppLogger.warning(error!, tag: 'CreateMatchVM');
        return false;
      }
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
        location: resolvedLocation,
        maxPlayers: int.tryParse(maxPlayersController.text.trim()) ?? 0,
      ).toJson();

      createdMatch = await _createRepo.createMatch(data);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMatchApi() async {
    if (!formKey.currentState!.validate()) return false;
    if (matchId == null || matchId!.isEmpty) {
      error = 'Match ID is missing';
      return false;
    }

    error = null;
    isLoading = true;
    notifyListeners();

    try {
      final resolvedLocation = await _resolveLocationForRequest();
      if (resolvedLocation.isEmpty) {
        error =
            'Location is required. Please allow location access or enter a location.';
        AppLogger.warning(error!, tag: 'CreateMatchVM');
        return false;
      }
      final data = {
        'title': matchTitleController.text.trim(),
        'description': descriptionController.text.trim(),
        'sport': selectedSportType,
        'skill_level': selectedSkillLevel,
        'scheduled_at': _buildScheduledAt(),
        'duration_minutes': duration,
        'location': resolvedLocation,
        'max_players': int.tryParse(maxPlayersController.text.trim()) ?? 0,
      };

      updatedMatch = await _updateRepo.updateMatch(
        matchId: matchId!,
        data: data,
      );
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitMatch() {
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
