import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/utils/logger.dart';
import '../../data/models/announcement_model.dart';

/// Local push notification service
class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
    );
    final linux = Platform.isLinux
        ? LinuxInitializationSettings(defaultActionName: 'Open notification')
        : null;
    final initSettings = InitializationSettings(
      android: android,
      iOS: ios,
      linux: linux,
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse? response) {
    if (response?.payload != null) {
      AppLogger.info('Notification tapped: ${response!.payload}');
    }
  }

  Future<void> showAnnouncementNotification(AnnouncementModel announcement) async {
    const androidDetails = AndroidNotificationDetails(
      'echo_announcements',
      'Announcements',
      channelDescription: 'Live public announcements',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      announcement.speechRecognized.hashCode,
      'ECHO Announcement',
      announcement.speechRecognized,
      details,
      payload: announcement.id ?? announcement.time,
    );
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }
}
