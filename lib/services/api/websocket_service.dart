import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/utils/logger.dart';
import '../../data/models/announcement_model.dart';

/// WebSocket service for live announcement updates
class WebSocketService {
  WebSocketService({String? baseUrl})
      : _baseUrl = baseUrl ?? 'wss://api.echo.app/ws';

  final String _baseUrl;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final _announcementController =
      StreamController<AnnouncementModel>.broadcast();

  Stream<AnnouncementModel> get announcementStream =>
      _announcementController.stream;

  bool get isConnected => _channel != null;

  void connect() {
    if (_channel != null) return;
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_baseUrl));
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
      AppLogger.info('WebSocket connected');
    } catch (e, s) {
      AppLogger.debug('WebSocket connect failed', e, s);
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    AppLogger.info('WebSocket disconnected');
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final announcement = AnnouncementModel.fromJson(data);
      _announcementController.add(announcement);
    } catch (e) {
      AppLogger.debug('WebSocket message parse error', e);
    }
  }

  void _onError(dynamic error) {
    AppLogger.debug('WebSocket error', error);
  }

  void _onDone() {
    _channel = null;
    _subscription = null;
    AppLogger.info('WebSocket connection closed');
  }
}
