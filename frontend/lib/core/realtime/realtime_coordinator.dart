import 'dart:async';

import 'package:frontend/core/realtime/realtime_connection.dart';

class RealtimeCoordinator {
  final RealtimeConnection connection;
  final Future<void> Function() onChanged;
  final Duration debounceDuration;
  final Duration retryDelay;

  StreamSubscription<void>? _subscription;
  Timer? _debounceTimer;
  bool _started = false;
  bool _disposed = false;

  RealtimeCoordinator({
    required this.connection,
    required this.onChanged,
    this.debounceDuration = const Duration(milliseconds: 150),
    this.retryDelay = const Duration(milliseconds: 750),
  });

  Future<void> start() async {
    if (_started || _disposed) return;
    _started = true;
    _subscription = connection.changes.listen((_) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(debounceDuration, _notify);
    });

    try {
      await connection.connect();
    } catch (_) {
      // El tiempo real no debe bloquear las vistas respaldadas por HTTP.
    }
  }

  void _notify() {
    if (_disposed) return;
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    try {
      await onChanged();
    } catch (_) {
      await Future<void>.delayed(retryDelay);
      if (_disposed) return;

      try {
        await onChanged();
      } catch (_) {
        // Los providers conservan su estado anterior y exponen el error HTTP.
      }
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _debounceTimer?.cancel();
    await _subscription?.cancel();
    await connection.dispose();
  }
}
