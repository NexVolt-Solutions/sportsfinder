import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show VoidCallback, kIsWeb;

/// Best-effort mobile reachability for gating WebSocket connects. Wi‑Fi without
/// DNS still reports "online"; real failures are handled separately via
/// [isTransientNetworkError] in socket paths.
class ChatConnectivityGate {
  ChatConnectivityGate._();
  static final ChatConnectivityGate instance = ChatConnectivityGate._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _started = false;
  bool _online = true;

  /// On web, [connectivity_plus] is not reliable; always attempt connections.
  bool get appearsReachable => kIsWeb ? true : _online;

  Future<void> ensureStarted() async {
    if (_started) return;
    _started = true;
    if (kIsWeb) return;
    try {
      final first = await _connectivity.checkConnectivity();
      _online = _coalesceOnline(first);
    } catch (_) {
      _online = true;
    }
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      final next = _coalesceOnline(results);
      if (next == _online) return;
      _online = next;
      if (_online) {
        _flushWaiters();
      }
    });
  }

  bool _coalesceOnline(List<ConnectivityResult> results) {
    if (results.isEmpty) return true;
    return results.any((r) => r != ConnectivityResult.none);
  }

  final List<VoidCallback> _waiters = [];

  /// Runs [callback] on the next microtask if reachable, or when connectivity returns.
  void whenReachable(VoidCallback callback) {
    if (kIsWeb || _online) {
      scheduleMicrotask(callback);
      return;
    }
    _waiters.add(callback);
  }

  void _flushWaiters() {
    if (!_online || _waiters.isEmpty) return;
    final copy = List<VoidCallback>.from(_waiters);
    _waiters.clear();
    for (final cb in copy) {
      try {
        cb();
      } catch (_) {}
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    _waiters.clear();
  }
}
