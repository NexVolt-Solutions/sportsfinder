/// API stores [duration_minutes] (int). These helpers map to / from a clock-style
/// hour / min / sec mental model. Sub-minute from the user is rounded to minutes.
int matchDurationHmsToTotalSeconds(int hours, int minutes, int seconds) {
  return hours * 3600 + minutes * 60 + seconds;
}

/// Minimum 1 min; max 12h for a single match.
int matchDurationHmsToApiMinutes(int hours, int minutes, int seconds) {
  var totalSec = matchDurationHmsToTotalSeconds(hours, minutes, seconds);
  if (totalSec < 60) totalSec = 60;
  if (totalSec > 12 * 3600) totalSec = 12 * 3600;
  return (totalSec / 60).round().clamp(1, 12 * 60);
}

({int h, int m, int s}) matchDurationHmsFromApiMinutes(int totalMinutes) {
  final m = totalMinutes.clamp(1, 12 * 60);
  final totalSec = m * 60;
  var h = totalSec ~/ 3600;
  var rem = totalSec % 3600;
  var min = rem ~/ 60;
  var s = rem % 60;
  return (h: h, m: min, s: s);
}

/// Shown in the form field for the [hours, minutes, seconds] the user picked.
String matchDurationHmsLabel(int hours, int minutes, int seconds) {
  if (hours == 0 && minutes == 0 && seconds == 0) {
    return '1 min';
  }
  if (hours == 0 && minutes == 0) {
    return seconds < 60 ? '1 min' : '${seconds}s';
  }
  final parts = <String>[];
  if (hours > 0) parts.add('${hours}h');
  if (minutes > 0) parts.add('${minutes}m');
  if (seconds > 0) parts.add('${seconds}s');
  if (parts.isEmpty) {
    return '1 min';
  }
  return parts.join(' ');
}

/// Label when we only have API minutes (no seconds).
String matchDurationLabelFromApiMinutes(int totalMinutes) {
  final m = totalMinutes.clamp(1, 12 * 60);
  final h = m ~/ 60;
  final min = m % 60;
  if (h == 0) {
    return min == 1 ? '1 min' : '$min min';
  }
  if (min == 0) {
    return '${h}h';
  }
  return '${h}h ${min}m';
}
