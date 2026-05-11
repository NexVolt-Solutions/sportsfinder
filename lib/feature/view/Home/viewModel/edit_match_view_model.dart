import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sport_finding/Data/Repositories/DeleteMatch/delete_match_repo.dart';
import 'package:sport_finding/Data/model/DeleteMAtch/delete_match_Model.dart';
import 'package:sport_finding/Data/Repositories/UpdateMatch/update_match_repo.dart';
import 'package:sport_finding/Data/model/UpdateMatch/update_match_model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/core/Network/google_places_service.dart';
import 'package:sport_finding/core/Network/places_search_result.dart';
import 'package:sport_finding/core/Constants/match_form_limits.dart';
import 'package:sport_finding/core/utils/match_duration_format.dart';
import 'package:sport_finding/core/utils/match_form_sport_labels.dart';
import 'package:sport_finding/core/Network/platform_options_store.dart';
import 'package:sport_finding/core/utils/api_error_message.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Network/location_selection_result.dart';

class EditMatchViewModel extends ChangeNotifier {
  bool _isDisposed = false;

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    Future<void>.microtask(() {
      if (_isDisposed) return;
      notifyListeners();
    });
  }

  final UpdateMatchRepo _updateRepo = UpdateMatchRepo();
  final DeleteMatchRepo _deleteRepo = DeleteMatchRepo();
  final GooglePlacesService _googlePlacesService = GooglePlacesService();

  final formKey = GlobalKey<FormState>();

  final matchTitleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final locationController = TextEditingController();
  final matchDurationController = TextEditingController();

  String? selectedSportType;
  String? selectedSkillLevel;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TimeOfDay get pickerInitialTime =>
      _selectedTime ?? _parseTimeText(timeController.text) ?? TimeOfDay.now();
  double? _selectedLatitude;
  double? _selectedLongitude;
  int duration = 60;
  int maxPlayers = 8;

  UpdateMatchModel? updatedMatch;
  DeleteMatchModel? deletedMatch;
  String? error;
  bool isLoading = false;
  bool isDeleting = false;
  String? matchId;

  /// From [GET /api/v1/options/] via [PlatformOptionsStore].
  List<String> sportTypes = [];
  List<String> skillLevels = [];
  bool optionsLoading = false;
  bool optionsLoaded = false;
  String? optionsError;

  Future<void> ensureOptionsLoaded() async {
    if (optionsLoaded) return;
    await Future<void>.microtask(() {});
    if (optionsLoaded) return;
    optionsLoading = true;
    optionsError = null;
    _safeNotifyListeners();
    try {
      final o = await PlatformOptionsStore.instance.load();
      sportTypes = List<String>.from(o.sports);
      skillLevels = List<String>.from(o.skills);
      optionsLoaded = true;
    } catch (e) {
      optionsError = e.toString();
      sportTypes = [];
      skillLevels = [];
    } finally {
      optionsLoading = false;
      _safeNotifyListeners();
    }
  }

  void populateForEdit(UpdateMatchModel match, BuildContext context) {
    matchId = match.id;

    matchTitleController.text = match.title ?? '';
    descriptionController.text = match.description ?? '';
    locationController.text = match.location ?? '';
    _selectedLatitude = match.latitude;
    _selectedLongitude = match.longitude;
    maxPlayers = MatchFormLimits.clampMaxPlayers(match.maxPlayers ?? 8);
    final fromMatchSport =
        sportValueForMatchDropdown(match.sport, sportTypes);
    final fromMatchSkill =
        skillValueForMatchDropdown(match.skillLevel, skillLevels);
    final profileDefaults = profileDefaultsForMatchForm(
      sportTypes,
      skillLevels,
    );
    selectedSportType = fromMatchSport ?? profileDefaults?.sport;
    selectedSkillLevel = fromMatchSkill ?? profileDefaults?.skill;

    duration = match.durationMinutes ?? 60;
    matchDurationController.text = matchDurationLabelFromApiMinutes(duration);

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
    _selectedLatitude = match.latitude;
    _selectedLongitude = match.longitude;
    maxPlayers = MatchFormLimits.clampMaxPlayers(match.participantsTotal);
    final fromMatchSport =
        sportValueForMatchDropdown(match.sportType, sportTypes);
    final fromMatchSkill =
        skillValueForMatchDropdown(match.skillLevel, skillLevels);
    final profileDefaults = profileDefaultsForMatchForm(
      sportTypes,
      skillLevels,
    );
    selectedSportType = fromMatchSport ?? profileDefaults?.sport;
    selectedSkillLevel = fromMatchSkill ?? profileDefaults?.skill;
    duration = match.durationMinutes > 0 ? match.durationMinutes : 60;
    matchDurationController.text = matchDurationLabelFromApiMinutes(duration);

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
      _selectedDate = _parseDateText(match.date);
      _selectedTime = _parseTimeText(match.time);
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
    _selectedDate ??= _parseDateText(dateController.text);
    _selectedTime = time;
    timeController.text = time.format(context);
  }

  DateTime? _parseDateText(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    final slash = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(text);
    if (slash != null) {
      final day = int.tryParse(slash.group(1)!);
      final month = int.tryParse(slash.group(2)!);
      final year = int.tryParse(slash.group(3)!);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(text);
    if (iso != null) {
      final year = int.tryParse(iso.group(1)!);
      final month = int.tryParse(iso.group(2)!);
      final day = int.tryParse(iso.group(3)!);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  TimeOfDay? _parseTimeText(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    final twelve = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(text);
    if (twelve != null) {
      var hour = int.tryParse(twelve.group(1)!);
      final minute = int.tryParse(twelve.group(2)!) ?? 0;
      final period = twelve.group(3)!.toUpperCase();
      if (hour == null) return null;
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    final twentyFour = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text);
    if (twentyFour != null) {
      final hour = int.tryParse(twentyFour.group(1)!);
      final minute = int.tryParse(twentyFour.group(2)!);
      if (hour != null && minute != null) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return null;
  }

  void setSelectedLocation(LocationSelectionResult selected) {
    locationController.text = selected.location.trim();
    _selectedLatitude = selected.latitude;
    _selectedLongitude = selected.longitude;
    notifyListeners();
  }

  void setMaxPlayers(int value) {
    maxPlayers = MatchFormLimits.clampMaxPlayers(value);
    notifyListeners();
  }

  void setDurationFromHms(int hours, int minutes, int seconds) {
    final sec = matchDurationHmsToTotalSeconds(hours, minutes, seconds);
    duration = matchDurationHmsToApiMinutes(hours, minutes, seconds);
    if (sec < 60) {
      matchDurationController.text = '1 min';
    } else {
      matchDurationController.text = matchDurationHmsLabel(
        hours,
        minutes,
        seconds,
      );
    }
    notifyListeners();
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

    return kIsWeb ? dt.toIso8601String() : dt.toUtc().toIso8601String();
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
    if (_buildScheduledAt() == null) {
      error = AppText.scheduleDateTimeRequired;
      notifyListeners();
      return false;
    }

    error = null;
    isLoading = true;
    notifyListeners();

    try {
      final resolvedLocation = locationController.text.trim();
      final coords = await _googlePlacesService.geocodeAddress(resolvedLocation);
      if (coords != null) {
        _selectedLatitude = coords.$1;
        _selectedLongitude = coords.$2;
      }
      final data = {
        'title': matchTitleController.text.trim(),
        'description': descriptionController.text.trim(),
        'sport': selectedSportType,
        'skill_level': selectedSkillLevel,
        'scheduled_at': _buildScheduledAt(),
        'scheduled_date': dateController.text.trim(),
        'scheduled_time': timeController.text.trim(),
        'duration_minutes': duration,
        'location': resolvedLocation,
        'latitude': _selectedLatitude,
        'longitude': _selectedLongitude,
        'max_players': maxPlayers,
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
      error = messageFromApiException(e);
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMatch() async {
    if (matchId == null || matchId!.trim().isEmpty) {
      error = 'Match ID is missing';
      notifyListeners();
      return false;
    }

    error = null;
    isDeleting = true;
    notifyListeners();

    try {
      deletedMatch = await _deleteRepo.deleteMatch(matchId: matchId!);
      return true;
    } catch (e, stackTrace) {
      debugPrint('Delete match failed: $e');
      debugPrint('$stackTrace');
      error = messageFromApiException(e);
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }

  Future<PlacesSearchResult> searchLocationSuggestions(String query) {
    return _googlePlacesService.searchPlaceSuggestions(query);
  }

  @override
  void dispose() {
    _isDisposed = true;
    matchTitleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    timeController.dispose();
    locationController.dispose();
    matchDurationController.dispose();
    super.dispose();
  }
}
