import 'package:sport_finding/core/Network/profile_service.dart';
import 'package:sport_finding/core/utils/edit_profile_sports_mapping.dart';

 
String? sportValueForMatchDropdown(String? raw, List<String> allowed) {
  if (raw == null) return null;
  final t = raw.trim();
  if (t.isEmpty) return null;
  if (allowed.contains(t)) return t;
  final mapped = apiSportToUiDropdown(t);
  if (mapped != null && allowed.contains(mapped)) return mapped;
  final low = t.toLowerCase();
  for (final a in allowed) {
    if (a.toLowerCase() == low) return a;
  }
  return null;
}

/// Resolves a raw [skill] string to a label in [allowed].
String? skillValueForMatchDropdown(String? raw, List<String> allowed) {
  if (raw == null) return null;
  final t = raw.trim();
  if (t.isEmpty) return null;
  if (allowed.contains(t)) return t;
  final mapped = apiSkillToUiDropdown(t);
  if (mapped != null && allowed.contains(mapped)) return mapped;
  final low = t.toLowerCase();
  for (final a in allowed) {
    if (a.toLowerCase() == low) return a;
  }
  return null;
}

/// First sport and skill from the signed-in profile, normalized to match form
/// dropdown options. Use when the match record uses API enums or different casing.
({String? sport, String? skill})? profileDefaultsForMatchForm(
  List<String> sportTypes,
  List<String> skillLevels,
) {
  final list = ProfileService().sports;
  if (list.isEmpty) return null;
  final first = list.first;
  if (first is! Map) return null;
  final m = Map<String, dynamic>.from(first);
  return (
    sport: sportValueForMatchDropdown(
      m['sport']?.toString(),
      sportTypes,
    ),
    skill: skillValueForMatchDropdown(
      m['skill_level']?.toString(),
      skillLevels,
    ),
  );
}
