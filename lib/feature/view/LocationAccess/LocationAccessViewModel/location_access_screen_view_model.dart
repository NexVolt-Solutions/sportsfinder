import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sport_finding/core/Network/google_places_service.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/utils/logger.dart';

class LocationAccessScreenViewModel extends ChangeNotifier {
  final GooglePlacesService _googlePlacesService = GooglePlacesService();

  bool _isRequestingLocation = false;
  bool get isRequestingLocation => _isRequestingLocation;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Location is on, device already has while-in-use (or always) — skip onboarding.
  Future<bool> hasUsableLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    final p = await Geolocator.checkPermission();
    return p == LocationPermission.whileInUse || p == LocationPermission.always;
  }

  /// Save coordinates + optional name without blocking the UI (after fast navigate).
  Future<void> saveLocationInBackground() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      final p = await Geolocator.checkPermission();
      if (p != LocationPermission.whileInUse &&
          p != LocationPermission.always) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final address = await _googlePlacesService.reverseGeocode(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      await AppPreferences.saveCurrentLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: address,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Background location save failed.',
        tag: 'LocationAccessScreen',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _fetchPositionAndPersist() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );
    final address = await _googlePlacesService.reverseGeocode(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    await AppPreferences.saveCurrentLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      locationName: address,
    );
  }

  /// "Allow location" — requests the system dialog only when [checkPermission] is [denied].
  /// If permission was already granted, returns success without re-requesting; location is
  /// saved in the background. If the user just granted, waits for a fix before returning.
  Future<bool> runAllowLocationFlow() async {
    AppLogger.info(
      'Allow location button tapped. Starting location flow.',
      tag: 'LocationAccessScreen',
    );

    _isRequestingLocation = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location services are disabled. Please turn them on.';
        AppLogger.warning(_errorMessage!, tag: 'LocationAccessScreen');
        return false;
      }

      final pre = await Geolocator.checkPermission();
      if (pre == LocationPermission.deniedForever) {
        _errorMessage =
            'Location permission is permanently denied. Please enable it from settings.';
        AppLogger.warning(_errorMessage!, tag: 'LocationAccessScreen');
        return false;
      }

      var permission = pre;
      if (pre == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        AppLogger.debug(
          'Location permission after request: $permission',
          tag: 'LocationAccessScreen',
        );
      }

      if (permission == LocationPermission.denied) {
        _errorMessage = 'Location permission was denied.';
        AppLogger.warning(_errorMessage!, tag: 'LocationAccessScreen');
        return false;
      }
      if (permission == LocationPermission.deniedForever) {
        _errorMessage =
            'Location permission is permanently denied. Please enable it from settings.';
        AppLogger.warning(_errorMessage!, tag: 'LocationAccessScreen');
        return false;
      }

      final hadPermissionBeforeRequest =
          pre == LocationPermission.whileInUse || pre == LocationPermission.always;
      if (hadPermissionBeforeRequest) {
        AppLogger.info(
          'Location permission already granted; navigating without blocking on GPS.',
          tag: 'LocationAccessScreen',
        );
        unawaited(saveLocationInBackground());
        return true;
      }

      await _fetchPositionAndPersist();
      AppLogger.success(
        'Location saved after new permission grant.',
        tag: 'LocationAccessScreen',
      );
      return true;
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to get current location.';
      AppLogger.error(
        'Location request failed.',
        tag: 'LocationAccessScreen',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _isRequestingLocation = false;
      notifyListeners();
    }
  }
}
