import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sport_finding/core/Constants/google_maps_config.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Network/google_places_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MatchLocationMapCard extends StatefulWidget {
  const MatchLocationMapCard({
    super.key,
    required this.location,
    this.latitude,
    this.longitude,
  });

  final String location;
  final double? latitude;
  final double? longitude;

  @override
  State<MatchLocationMapCard> createState() => _MatchLocationMapCardState();
}

class _MatchLocationMapCardState extends State<MatchLocationMapCard> {
  final GooglePlacesService _places = GooglePlacesService();
  (double, double)? _resolvedCoords;
  bool _resolving = false;

  @override
  void initState() {
    super.initState();
    if (_hasCoordinates) {
      _resolvedCoords = (widget.latitude!, widget.longitude!);
    } else {
      _resolveFromAddress();
    }
  }

  bool get _hasCoordinates => widget.latitude != null && widget.longitude != null;

  Future<void> _resolveFromAddress() async {
    if (widget.location.trim().isEmpty) return;
    setState(() => _resolving = true);
    final coords = await _places.geocodeAddress(widget.location);
    if (!mounted) return;
    setState(() {
      _resolvedCoords = coords;
      _resolving = false;
    });
  }

  String get _encodedLocation {
    if (_resolvedCoords != null) {
      return Uri.encodeComponent('${_resolvedCoords!.$1},${_resolvedCoords!.$2}');
    }
    return Uri.encodeComponent(widget.location.trim());
  }

  Future<void> _openInGoogleMaps() async {
    if (_resolvedCoords == null && widget.location.trim().isEmpty) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$_encodedLocation',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final coords = _resolvedCoords;
    final hasMap = GoogleMapsConfig.hasApiKey && coords != null;
    final mapCenter = coords != null
        ? LatLng(coords.$1, coords.$2)
        : const LatLng(0, 0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(context.radius(12)),
      child: SizedBox(
        height: context.h(174),
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: hasMap
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: mapCenter,
                        zoom: 15,
                      ),
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      markers: {
                        Marker(
                          markerId: const MarkerId('match_location'),
                          position: mapCenter,
                        ),
                      },
                    )
                  : _MapFallback(
                      location: widget.location,
                      onTap: _openInGoogleMaps,
                      loading: _resolving,
                    ),
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
  const _MapFallback({
    required this.location,
    required this.onTap,
    this.loading = false,
  });

  final String location;
  final Future<void> Function() onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: context.appColors.blue10,
        child: Center(
          child: Padding(
            padding: context.paddingSymmetric(horizontal: 16, vertical: 20),
            child: loading
                ? const CircularProgressIndicator(strokeWidth: 2)
                : Text(
                    location,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.appText.text14W500.copyWith(
                      color: context.appColors.onSurface,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
