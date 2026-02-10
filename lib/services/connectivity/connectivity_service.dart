import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity monitoring service
class ConnectivityService {
  ConnectivityService() : _connectivity = Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<ConnectivityResult>? _subscription;
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get isConnectedStream => _controller.stream;

  bool _lastKnown = true;
  bool get isConnected => _lastKnown;

  bool _isConnected(ConnectivityResult r) =>
      r == ConnectivityResult.wifi ||
      r == ConnectivityResult.mobile ||
      r == ConnectivityResult.ethernet;

  Future<void> init() async {
    _lastKnown = await checkConnection();
    _controller.add(_lastKnown);
    _subscription = _connectivity.onConnectivityChanged.listen(_onChange);
  }

  void _onChange(ConnectivityResult result) {
    final connected = _isConnected(result);
    if (connected != _lastKnown) {
      _lastKnown = connected;
      _controller.add(connected);
    }
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
