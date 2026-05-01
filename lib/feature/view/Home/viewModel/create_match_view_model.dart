import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sport_finding/Data/Repositories/UpdateMatch/update_match_repo.dart';
import 'package:sport_finding/Data/Repositories/create_match_repo.dart';
import 'package:sport_finding/Data/model/UpdateMatch/update_match_model.dart';
import 'package:sport_finding/Data/model/create_match_request_model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/core/Network/google_places_service.dart';
import 'package:sport_finding/core/Network/places_search_result.dart';
import 'package:sport_finding/core/Constants/match_form_limits.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/utils/logger.dart';
import 'package:sport_finding/core/utils/match_duration_format.dart';
import 'package:sport_finding/core/utils/match_form_sport_labels.dart';
import 'package:sport_finding/core/Network/platform_options_store.dart';
import 'package:sport_finding/core/utils/api_error_message.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Network/location_selection_result.dart';

class CreateMatchViewModel extends ChangeNotifier {
  bool _isDisposed = false;

  List<String> _normalizeOptions(List<String> raw) {
    final dedup = <String>{};
    final result = <String>[];
    for (final item in raw) {
      final trimmed = item.trim();
      if (trimmed.isEmpty) continue;
      final key = trimmed.toLowerCase();
      if (dedup.add(key)) {
        result.add(trimmed);
      }
    }
    return result;
  }

  void _safeNotifyListeners() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      notifyListeners();
    });
  }

  final CreateMatchRepo _createRepo = CreateMatchRepo();
  final UpdateMatchRepo _updateRepo = UpdateMatchRepo();
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
  TimeOfDay get pickerInitialTime => _selectedTime ?? _parseTimeText(timeController.text) ?? TimeOfDay.now();
  double? _selectedLatitude;
  double? _selectedLongitude;
  int duration = 60;
  int maxPlayers = 8;

  MatchModel? createdMatch;
  UpdateMatchModel? updatedMatch;
  String? error;
  bool isLoading = false;

  bool isEditMode = false;
  String? matchId;

  CreateMatchViewModel() {
    matchDurationController.text = matchDurationLabelFromApiMinutes(duration);
    _hydrateSavedLocation();
    unawaited(ensureOptionsLoaded());
  }

  /// From [GET /api/v1/options/] via [PlatformOptionsStore].
  List<String> sportTypes = [];
  List<String> skillLevels = [];
  bool optionsLoading = false;
  bool optionsLoaded = false;
  String? optionsError;

  Future<void> ensureOptionsLoaded() async {
    if (optionsLoaded) return;
    // Do not [notifyListeners] from the first synchronous part of
    // [State.didChangeDependencies] — that runs during a parent’s build
    // and triggers the framework `!_dirty` assertion.
    await Future<void>.microtask(() {});
    if (optionsLoaded) return;
    optionsLoading = true;
    optionsError = null;
    _safeNotifyListeners();
    try {
      final o = await PlatformOptionsStore.instance.load();
      sportTypes = _normalizeOptions(o.sports);
      skillLevels = _normalizeOptions(o.skills);
      optionsLoaded = sportTypes.isNotEmpty && skillLevels.isNotEmpty;
      if (!optionsLoaded) {
        optionsError =
            'Options API returned empty sports/skills. Please try again.';
        AppLogger.warning(optionsError!, tag: 'CreateMatchVM');
      }
      if (selectedSportType != null && !sportTypes.contains(selectedSportType)) {
        selectedSportType = null;
      }
      if (selectedSkillLevel != null &&
          !skillLevels.contains(selectedSkillLevel)) {
        selectedSkillLevel = null;
      }
    } catch (e) {
      optionsError = e.toString();
      sportTypes = <String>[];
      skillLevels = <String>[];
      optionsLoaded = false;
      AppLogger.warning('Options API failed: $e', tag: 'CreateMatchVM');
    } finally {
      optionsLoading = false;
      _safeNotifyListeners();
    }
  }

  void populateForEdit(UpdateMatchModel match, BuildContext context) {
    isEditMode = true;
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
    selectedSportType = fromMatchSport;
    selectedSkillLevel = fromMatchSkill;

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
    isEditMode = true;
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
    selectedSportType = fromMatchSport;
    selectedSkillLevel = fromMatchSkill;
    matchDurationController.text = matchDurationLabelFromApiMinutes(duration);

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

  /// [AppPreferences] may only have lat/lng (stored as "lat,lng") when geocoding failed earlier.
  static final RegExp _latLngPairPattern = RegExp(
    r'^\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*$',
  );

  static bool _looksLikeLatLngPair(String s) {
    return _latLngPairPattern.hasMatch(s.trim());
  }

  static (double, double)? _tryParseLatLngPair(String s) {
    final m = _latLngPairPattern.firstMatch(s.trim());
    if (m == null) return null;
    final lat = double.tryParse(m.group(1)!);
    final lng = double.tryParse(m.group(2)!);
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }

   Future<String> _humanReadableLocation(String raw) async {
    final t = raw.trim();
    if (t.isEmpty) return '';
    final m = _latLngPairPattern.firstMatch(t);
    if (m == null) return t;
    final lat = double.tryParse(m.group(1)!);
    final lng = double.tryParse(m.group(2)!);
    if (lat == null || lng == null) return t;
    final address = await _googlePlacesService.reverseGeocode(
      latitude: lat,
      longitude: lng,
    );
    if (address != null && address.isNotEmpty) {
      return address;
    }
    return t;
  }

  Future<void> _hydrateSavedLocation() async {
    if (locationController.text.trim().isNotEmpty) return;
    var name = await AppPreferences.getCurrentLocationName();
    var savedLocation = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : await AppPreferences.getCurrentLocationText();

    if (savedLocation == null || savedLocation.trim().isEmpty) {
      final coords = await AppPreferences.getCurrentLocation();
      if (coords == null) {
        AppLogger.warning(
          'No saved exact location found for create match form.',
          tag: 'CreateMatchVM',
        );
        return;
      }
      savedLocation = '${coords.$1},${coords.$2}';
    } else {
      savedLocation = savedLocation.trim();
    }

    if (_looksLikeLatLngPair(savedLocation)) {
      final m = _latLngPairPattern.firstMatch(savedLocation)!;
      var lat = double.parse(m.group(1)!);
      var lng = double.parse(m.group(2)!);
      final coords = await AppPreferences.getCurrentLocation();
      if (coords != null) {
        lat = coords.$1;
        lng = coords.$2;
      }
      final address = await _googlePlacesService.reverseGeocode(
        latitude: lat,
        longitude: lng,
      );
      if (address != null && address.isNotEmpty) {
        savedLocation = address;
        await AppPreferences.saveCurrentLocation(
          latitude: lat,
          longitude: lng,
          locationName: address,
        );
      }
    }

    locationController.text = savedLocation;
    AppLogger.info(
      'Loaded saved exact location into create match form: $savedLocation',
      tag: 'CreateMatchVM',
    );
    _safeNotifyListeners();
  }

  Future<String> _resolveLocationForRequest() async {
    var typedLocation = locationController.text.trim();
    if (typedLocation.isNotEmpty) {
      typedLocation = await _humanReadableLocation(typedLocation);
      final coords = await _googlePlacesService.geocodeAddress(typedLocation);
      if (coords != null) {
        _selectedLatitude = coords.$1;
        _selectedLongitude = coords.$2;
      }
      if (locationController.text.trim() != typedLocation) {
        locationController.text = typedLocation;
        if (!_isDisposed) {
          notifyListeners();
        }
      }
      _selectedLatitude ??= _tryParseLatLngPair(typedLocation)?.$1;
      _selectedLongitude ??= _tryParseLatLngPair(typedLocation)?.$2;
      AppLogger.debug(
        'Using location from form field: $typedLocation',
        tag: 'CreateMatchVM',
      );
      return typedLocation;
    }

    var savedLocation = await AppPreferences.getCurrentLocationName() ??
        await AppPreferences.getCurrentLocationText();
    if (savedLocation != null && savedLocation.trim().isNotEmpty) {
      final trimmed = savedLocation.trim();
      var resolved = await _humanReadableLocation(trimmed);
      final coords = await AppPreferences.getCurrentLocation() ??
          _tryParseLatLngPair(trimmed);
      if (resolved != trimmed && coords != null) {
        await AppPreferences.saveCurrentLocation(
          latitude: coords.$1,
          longitude: coords.$2,
          locationName: resolved,
        );
      }
      locationController.text = resolved;
      if (coords != null) {
        _selectedLatitude = coords.$1;
        _selectedLongitude = coords.$2;
      }
      AppLogger.info(
        'Location field was empty, using saved exact location: $resolved',
        tag: 'CreateMatchVM',
      );
      return resolved;
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
    if (isLoading) return false;
    if (!formKey.currentState!.validate()) return false;
    if (_buildScheduledAt() == null) {
      error = AppText.scheduleDateTimeRequired;
      if (!_isDisposed) {
        notifyListeners();
      }
      return false;
    }

    error = null;
    isLoading = true;
    if (!_isDisposed) {
      notifyListeners();
    }

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
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
        maxPlayers: maxPlayers,
      ).toJson();

      createdMatch = await _createRepo.createMatch(data);
      return true;
    } catch (e) {
      error = messageFromApiException(e);
      return false;
    } finally {
      isLoading = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  Future<bool> updateMatchApi() async {
    if (isLoading) return false;
    if (!formKey.currentState!.validate()) return false;
    if (matchId == null || matchId!.isEmpty) {
      error = 'Match ID is missing';
      return false;
    }
    if (_buildScheduledAt() == null) {
      error = AppText.scheduleDateTimeRequired;
      if (!_isDisposed) {
        notifyListeners();
      }
      return false;
    }

    error = null;
    isLoading = true;
    if (!_isDisposed) {
      notifyListeners();
    }

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
        'scheduled_date': dateController.text.trim(),
        'scheduled_time': timeController.text.trim(),
        'duration_minutes': duration,
        'location': resolvedLocation,
        'latitude': _selectedLatitude,
        'longitude': _selectedLongitude,
        'max_players': maxPlayers,
      };

      updatedMatch = await _updateRepo.updateMatch(
        matchId: matchId!,
        data: data,
      );
      return true;
    } catch (e) {
      error = messageFromApiException(e);
      return false;
    } finally {
      isLoading = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  Future<bool> submitMatch() {
    return isEditMode ? updateMatchApi() : createMatchApi();
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
