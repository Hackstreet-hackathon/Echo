import 'package:intl/intl.dart';

/// Date/time formatting utilities for ECHO
class AppDateUtils {
  AppDateUtils._();

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y • HH:mm').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDateTime(dateTime);
  }

  static DateTime? parseIso8601(String? value) {
    if (value == null) return null;
    return DateTime.tryParse(value);
  }
}
