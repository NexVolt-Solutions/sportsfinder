import 'package:geolocator/geolocator.dart';
import 'package:sport_finding/core/Network/google_places_service.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/core/utils/logger.dart';

/// Location services are enabled and the app has usable foreground location permission.
Future<bool> hasUsableLocationForOnboarding() async {
  if (!await Geolocator.isLocationServiceEnabled()) return false;
  final p = await Geolocator.checkPermission();
  return p == LocationPermission.whileInUse || p == LocationPermission.always;
}

/// Saves coordinates + optional reverse-geocoded label for onboarding sync.
Future<void> persistCurrentLocationFromDevice() async {
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
    final googlePlacesService = GooglePlacesService();
    final address = await googlePlacesService.reverseGeocode(
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
      tag: 'LocationOnboardingGate',
      error: e,
      stackTrace: stackTrace,
    );
  }
}
