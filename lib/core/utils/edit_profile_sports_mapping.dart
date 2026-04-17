import 'package:sport_finding/core/Constants/app_text.dart';

/// Maps API `/users/me` sport strings to UI dropdown labels.
String? apiSportToUiDropdown(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final s = raw.trim().toUpperCase().replaceAll(' ', '_');
  if (s.contains('BASKET')) return AppText.basketball;
  if (s.contains('VOLLEY')) return AppText.volleyball;
  if (s.contains('TENNIS')) return AppText.tennis;
  if (s.contains('FOOT') || s == 'SOCCER') return AppText.football;
  for (final o in [
    AppText.basketball,
    AppText.football,
    AppText.tennis,
    AppText.volleyball,
  ]) {
    if (o.toLowerCase() == raw.trim().toLowerCase()) return o;
  }
  return null;
}

/// Maps API skill strings to UI dropdown labels.
String? apiSkillToUiDropdown(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final s = raw.trim().toUpperCase();
  if (s.contains('BEGIN')) return AppText.beginner;
  if (s.contains('INTER')) return AppText.intermediate;
  if (s.contains('ADV')) return AppText.advanced;
  for (final o in [AppText.beginner, AppText.intermediate, AppText.advanced]) {
    if (o.toLowerCase() == raw.trim().toLowerCase()) return o;
  }
  return null;
}

/// UI labels → API tokens for `sports` JSON in multipart body.
String uiSportToApiToken(String ui) {
  switch (ui) {
    case AppText.basketball:
      return 'Basketball';
    case AppText.football:
      return 'Football';
    case AppText.tennis:
      return 'Tennis';
    case AppText.volleyball:
      return 'Volleyball';
    default:
      return ui.trim();
  }
}

String uiSkillToApiToken(String ui) {
  switch (ui) {
    case AppText.beginner:
      return 'Beginner';
    case AppText.intermediate:
      return 'Intermediate';
    case AppText.advanced:
      return 'Advanced';
    default:
      return ui.trim();
  }
}
