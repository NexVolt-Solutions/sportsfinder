import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Network/api_service.dart';

String? normalizeImageUrl(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  if (uri != null && uri.hasScheme) {
    if (uri.isScheme('http') ||
        uri.isScheme('https') ||
        uri.isScheme('data') ||
        uri.isScheme('blob')) {
      return trimmed;
    }
  }
  final base = ApiService().baseUrl.trim();
  if (trimmed.startsWith('//')) return 'https:$trimmed';
  if (trimmed.startsWith('/')) return '$base$trimmed';
  return '$base/$trimmed';
}

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.size,
    this.imageUrl,
    this.fallbackText,
    this.backgroundColor,
    this.icon,
    this.iconColor,
  });

  final double size;
  final String? imageUrl;
  final String? fallbackText;
  final Color? backgroundColor;
  final IconData? icon;
  final Color? iconColor;

  String _initials() {
    final text = (fallbackText ?? '').trim();
    if (text.isEmpty) return '';
    return text.length >= 2
        ? text.substring(0, 2).toUpperCase()
        : text.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = normalizeImageUrl(imageUrl);
    final bg = backgroundColor ?? context.appColors.blue10;
    final fg = iconColor ?? context.appColors.primary;

    Widget fallback() {
      final initials = _initials();
      if (initials.isNotEmpty) {
        return Text(
          initials,
          style: context.appText.text14W600.copyWith(color: fg),
        );
      }
      return Icon(icon ?? Icons.person_rounded, color: fg, size: size * 0.42);
    }

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: bg,
        child: normalizedUrl == null
            ? Center(child: fallback())
            : Image.network(
                normalizedUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Center(child: fallback()),
              ),
      ),
    );
  }
}
