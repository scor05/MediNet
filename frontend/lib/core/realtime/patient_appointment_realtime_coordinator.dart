import 'dart:async';

import 'package:frontend/core/realtime/patient_appointment_realtime_connection.dart';

class PatientAppointmentRealtimeCoordinator {
  final PatientAppointmentRealtimeConnection connection;
  final Future<void> Function() onAppointmentChanged;
  final Duration debounceDuration;
  final Duration retryDelay;

  StreamSubscription<void>? _subscription;
  Timer? _debounceTimer;
  bool _started = false;
  bool _disposed = false;

  PatientAppointmentRealtimeCoordinator({
    required this.connection,
    required this.onAppointmentChanged,
    this.debounceDuration = const Duration(milliseconds: 150),
    this.retryDelay = const Duration(milliseconds: 750),
  });

  Future<void> start() async {
    if (_started || _disposed) return;
    _started = true;
    _subscription = connection.changes.listen((_) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(debounceDuration, _notifyCalendar);
    });

    try {
      await connection.connect();
    } catch (_) {
      // La actualización en tiempo real no debe bloquear el calendario HTTP.
    }
  }

  void _notifyCalendar() {
    if (_disposed) return;
    unawaited(_refreshCalendar());
  }

  Future<void> _refreshCalendar() async {
    try {
      await onAppointmentChanged();
    } catch (_) {
      await Future<void>.delayed(retryDelay);
      if (_disposed) return;

      try {
        await onAppointmentChanged();
      } catch (_) {
        // El calendario conserva los datos anteriores y muestra el error.
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
