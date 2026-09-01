import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/realtime/patient_appointment_realtime_connection.dart';
import 'package:frontend/core/realtime/patient_appointment_realtime_coordinator.dart';

void main() {
  test('coalesces appointment events and disposes the connection', () async {
    final connection = _FakeConnection();
    var refreshes = 0;
    final coordinator = PatientAppointmentRealtimeCoordinator(
      connection: connection,
      debounceDuration: const Duration(milliseconds: 10),
      onAppointmentChanged: () async {
        refreshes++;
      },
    );

    await coordinator.start();
    connection.emitChange();
    connection.emitChange();
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(connection.connectCalls, 1);
    expect(refreshes, 1);

    await coordinator.dispose();
    expect(connection.disposeCalls, 1);
  });

  test('does not refresh after disposal', () async {
    final connection = _FakeConnection();
    var refreshes = 0;
    final coordinator = PatientAppointmentRealtimeCoordinator(
      connection: connection,
      debounceDuration: const Duration(milliseconds: 10),
      onAppointmentChanged: () async {
        refreshes++;
      },
    );

    await coordinator.start();
    connection.emitChange();
    await coordinator.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(refreshes, 0);
  });

  test('retries a failed calendar refresh once', () async {
    final connection = _FakeConnection();
    var refreshes = 0;
    final coordinator = PatientAppointmentRealtimeCoordinator(
      connection: connection,
      debounceDuration: const Duration(milliseconds: 5),
      retryDelay: const Duration(milliseconds: 5),
      onAppointmentChanged: () async {
        refreshes++;
        if (refreshes == 1) throw Exception('temporary failure');
      },
    );

    await coordinator.start();
    connection.emitChange();
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(refreshes, 2);
    await coordinator.dispose();
  });
}

class _FakeConnection implements PatientAppointmentRealtimeConnection {
  final _changes = StreamController<void>.broadcast();
  int connectCalls = 0;
  int disposeCalls = 0;

  @override
  Stream<void> get changes => _changes.stream;

  void emitChange() => _changes.add(null);

  @override
  Future<void> connect() async {
    connectCalls++;
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
    await _changes.close();
  }
}
