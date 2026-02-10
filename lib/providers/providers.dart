import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api/api_service.dart';
import '../services/api/websocket_service.dart';
import '../services/auth/auth_service.dart';
import '../services/cache/cache_service.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/notification/notification_service.dart';
import '../services/speech/speech_service.dart';
import '../services/storage/preferences_service.dart';
import '../services/data/train_service.dart';

final trainFilterProvider = StateProvider<String>((ref) => 'All');

final trainServiceProvider = Provider((ref) => TrainService());

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(() => service.disconnect());
  return service;
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final speechServiceProvider = Provider<SpeechService>((ref) => SpeechService());

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

final preferencesServiceProvider =
    Provider<PreferencesService>((ref) => PreferencesService());
