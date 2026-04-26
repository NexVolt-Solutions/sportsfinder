import 'package:intl/intl.dart';
import 'package:sport_finding/core/Constants/app_text.dart';

class DateTimeFormatters {
  DateTimeFormatters._();

  static String chatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  static String chatDate(DateTime dateTime) {
    return DateFormat('d MMMM yyyy').format(dateTime);
  }

  static String relativeLabel(DateTime dateTime) {
    final local = dateTime.toLocal();
    final diff = DateTime.now().difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) {
      final minutes = diff.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      final hours = diff.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }
    final days = diff.inDays;
    if (days <= 1) return AppText.yesterday;
    return '$days day${days == 1 ? '' : 's'} ago';
  }
}
