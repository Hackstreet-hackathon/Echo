/// Application-wide constants
class AppConstants {
  AppConstants._();

  static const String appName = 'ECHO';
  static const String cacheBoxName = 'echo_cache';
  static const String announcementsBoxName = 'announcements';
  static const String favoritesBoxName = 'favorites';
  static const String historyBoxName = 'history';
  static const String settingsBoxName = 'settings';

  static const int maxHistoryItems = 100;
  static const int maxFavoritesItems = 50;
  static const Duration announcementRefreshInterval = Duration(seconds: 30);
  static const Duration cacheExpiryDuration = Duration(hours: 24);
}
