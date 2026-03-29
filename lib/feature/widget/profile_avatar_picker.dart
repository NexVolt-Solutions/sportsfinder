import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';

/// Avatar with optional local image file and a tappable camera badge.
/// UI-only: parent supplies [imagePath] and [onPickPressed].
class ProfileAvatarPicker extends StatelessWidget {
  const ProfileAvatarPicker({
    super.key,
    required this.radius,
    required this.onPickPressed,
    this.imagePath,
    this.placeholderBackgroundColor,
    this.placeholderIconColor,
  });

  final double radius;
  final VoidCallback onPickPressed;

  /// Local filesystem path from [ImagePicker] (ignored on web).
  final String? imagePath;
  final Color? placeholderBackgroundColor;
  final Color? placeholderIconColor;

  ImageProvider? get _imageProvider {
    if (kIsWeb) return null;
    final path = imagePath;
    if (path == null || path.isEmpty) return null;
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bg = placeholderBackgroundColor ?? colors.greylight;
    final iconColor = placeholderIconColor ?? colors.greyDark;
    final provider = _imageProvider;
    final badgePadding = radius * 0.14;
    final iconSize = radius * 0.38;

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: bg,
            backgroundImage: provider,
            child: provider == null
                ? Icon(Icons.person, size: radius * 1.12, color: iconColor)
                : null,
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Material(
              color: colors.onPrimary,
              shape: const CircleBorder(),
              elevation: 3,
              shadowColor: colors.greyDark.withValues(alpha: 0.35),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPickPressed,
                child: Padding(
                  padding: EdgeInsets.all(badgePadding),
                  child: Icon(
                    Icons.camera_alt,
                    size: iconSize,
                    color: colors.greyDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
