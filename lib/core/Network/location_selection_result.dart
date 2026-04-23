class LocationSelectionResult {
  const LocationSelectionResult({
    required this.location,
    this.latitude,
    this.longitude,
  });

  final String location;
  final double? latitude;
  final double? longitude;
}
