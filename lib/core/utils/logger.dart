import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void info(String message, {String tag = 'App'}) {
    debugPrint('[INFO][$tag] $message');
  }

  static void debug(String message, {String tag = 'App'}) {
    debugPrint('[DEBUG][$tag] $message');
  }

  static void success(String message, {String tag = 'App'}) {
    debugPrint('[SUCCESS][$tag] $message');
  }

  static void warning(String message, {String tag = 'App'}) {
    debugPrint('[WARNING][$tag] $message');
  }

  static void error(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    debugPrint('[ERROR][$tag] $message');
    if (error != null) {
      debugPrint('[ERROR][$tag] $error');
    }
    if (stackTrace != null) {
      debugPrint('[ERROR][$tag] $stackTrace');
    }
  }
}
