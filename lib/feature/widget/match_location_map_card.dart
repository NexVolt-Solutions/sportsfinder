import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/google_maps_config.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class MatchLocationMapCard extends StatelessWidget {
  const MatchLocationMapCard({
    super.key,
    required this.location,
    this.latitude,
    this.longitude,
  });

  final String location;
  final double? latitude;
  final double? longitude;

  bool get _hasCoordinates => latitude != null && longitude != null;

  String get _encodedLocation {
    if (_hasCoordinates) {
      return Uri.encodeComponent('${latitude!},${longitude!}');
    }
    return Uri.encodeComponent(location.trim());
  }

  String get _staticMapUrl {
    final key = GoogleMapsConfig.webServicesKey;
    if (key.isEmpty || (_hasCoordinates ? false : location.trim().isEmpty)) {
      return '';
    }
    final center = _hasCoordinates ? '${latitude!},${longitude!}' : location.trim();
    final marker = _hasCoordinates
        ? 'color:red|${latitude!},${longitude!}'
        : 'color:red|$location';
    final params = <String, String>{
      'center': center,
      'zoom': '15',
      'size': '900x450',
      'scale': '2',
      'maptype': 'roadmap',
      'markers': marker,
      'key': key,
    };
    return Uri.https('maps.googleapis.com', '/maps/api/staticmap', params)
        .toString();
  }

  Future<void> _openInGoogleMaps() async {
    if (!_hasCoordinates && location.trim().isEmpty) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$_encodedLocation',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final hasMapPreview = _staticMapUrl.isNotEmpty;
    return GestureDetector(
      onTap: _openInGoogleMaps,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.radius(12)),
        child: Stack(
          children: [
            Container(
              height: context.h(174),
              width: double.infinity,
              color: context.appColors.blue10,
              child: hasMapPreview
                  ? Image.network(
                      _staticMapUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stackTrace) => _MapFallback(
                        location: location,
                        onTap: _openInGoogleMaps,
                      ),
                    )
                  : _MapFallback(location: location, onTap: _openInGoogleMaps),
            ),
            const Center(
              child: Icon(Icons.location_pin, size: 42, color: Colors.red),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.open_in_new, size: 20),
                  onPressed: _openInGoogleMaps,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapFallback extends StatelessWidget {
  const _MapFallback({required this.location, required this.onTap});

  final String location;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: context.padAll(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              color: context.appColors.primary,
              size: 28,
            ),
            SizedBox(height: context.h(8)),
            Text(
              location,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.appText.text14W500.copyWith(
                color: context.appColors.onSurface,
              ),
            ),
            SizedBox(height: context.h(6)),
            Text(
              'Tap to open in Google Maps',
              style: context.appText.text12W400.copyWith(
                color: context.appColors.greyDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
