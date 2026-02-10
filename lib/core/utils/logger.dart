import 'package:flutter/foundation.dart';

/// Simple logger utility for ECHO
class AppLogger {
  AppLogger._();

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[ECHO DEBUG] $message');
      if (error != null) {
        // ignore: avoid_print
        print('[ECHO ERROR] $error');
        if (stackTrace != null) {
          // ignore: avoid_print
          print(stackTrace);
        }
      }
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[ECHO INFO] $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[ECHO WARNING] $message');
    }
  }
}
