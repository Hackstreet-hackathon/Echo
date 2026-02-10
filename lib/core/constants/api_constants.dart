/// API endpoint constants for ECHO backend
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.echo.app',
  );

  static const String announcements = '/announcements';
  static String announcementByName(String name) => '/announcements/$name';
  static String platformByNumber(int num) => '/platform/$num';
  static const String upload = '/upload';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
