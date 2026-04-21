import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sport_finding/core/Network/google_places_service.dart';
import 'package:sport_finding/core/utils/logger.dart';

class LocationAccessScreenViewModel extends ChangeNotifier {
  final GooglePlacesService _googlePlacesService = GooglePlacesService();

  bool _isRequestingLocation = false;
  bool get isRequestingLocation => _isRequestingLocation;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  String? _currentAddress;
  String? get currentAddress => _currentAddress;

  Future<bool> requestCurrentLocation() async {
    AppLogger.info(
      'Allow location button tapped. Starting location flow.',
      tag: 'LocationAccessScreen',
    );

    _isRequestingLocation = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      AppLogger.debug(
        'Location service enabled: $serviceEnabled',
        tag: 'LocationAccessScreen',
      );

      if (!serviceEnabled) {
        _errorMessage = 'Location services are disabled. Please turn them on.';
        AppLogger.warning(_errorMessage!, tag: 'LocationAccessScreen');
        return false;
      }

      var permission = await Geolocator.checkPermission();
      AppLogger.debug(
        'Initial location permission: $permission',
        tag: 'LocationAccessScreen',
      );

      if (permission == LocationPermission.denied) {
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
      final position = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          forceLocationManager: false,
          intervalDuration: const Duration(seconds: 5),
        ),
      );

      _currentPosition = position;
      _currentAddress = await _googlePlacesService.reverseGeocode(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      AppLogger.success(
        'Exact location fetched successfully.',
        tag: 'LocationAccessScreen',
      );
      AppLogger.debug(
        'Latitude: ${position.latitude}, Longitude: ${position.longitude}',
        tag: 'LocationAccessScreen',
      );
      if (_currentAddress != null && _currentAddress!.isNotEmpty) {
        AppLogger.debug(
          'Resolved current address: $_currentAddress',
          tag: 'LocationAccessScreen',
        );
      }
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
