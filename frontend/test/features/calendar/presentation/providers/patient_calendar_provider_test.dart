import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';
import 'package:frontend/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:frontend/features/appointment/domain/usecases/get_patient_appointments_usecase.dart';
import 'package:frontend/features/calendar/presentation/providers/patient_calendar_provider.dart';

void main() {
  const patientId = 11;

  test('keeps current appointments visible while realtime refreshes', () async {
    final initial = [_appointment(1)];
    final refreshed = [_appointment(1), _appointment(2)];
    final repository = _PatientCalendarRepository(initial);
    final container = _container(repository);
    addTearDown(container.dispose);

    expect(
      await container.read(patientCalendarNotifierProvider(patientId).future),
      initial,
    );

    final refresh = container
        .read(patientCalendarNotifierProvider(patientId).notifier)
        .refreshAll();
    await Future<void>.delayed(Duration.zero);

    final loadingState = container.read(
      patientCalendarNotifierProvider(patientId),
    );
    expect(loadingState.isLoading, isTrue);
    expect(loadingState.requireValue, initial);

    repository.refreshCompleter.complete(refreshed);
    await refresh;

    expect(
      container.read(patientCalendarNotifierProvider(patientId)).requireValue,
      refreshed,
    );
  });

  test(
    'keeps current appointments and exposes realtime refresh error',
    () async {
      final initial = [_appointment(1)];
      final repository = _PatientCalendarRepository(initial);
      final container = _container(repository);
      addTearDown(container.dispose);

      expect(
        await container.read(patientCalendarNotifierProvider(patientId).future),
        initial,
      );

      final refresh = container
          .read(patientCalendarNotifierProvider(patientId).notifier)
          .refreshAll();
      repository.refreshCompleter.completeError(Exception('network error'));
      await expectLater(refresh, throwsException);

      final state = container.read(patientCalendarNotifierProvider(patientId));
      expect(state.hasError, isTrue);
      expect(state.requireValue, initial);
    },
  );

  test('only exposes appointments owned by the active patient', () async {
    final repository = _PatientCalendarRepository([
      _appointment(1),
      _appointment(2, patientId: 99),
    ]);
    final container = _container(repository);
    addTearDown(container.dispose);

    final appointments = await container.read(
      patientCalendarNotifierProvider(patientId).future,
    );

    expect(appointments.map((appointment) => appointment.id), [1]);
    expect(
      appointments.every((appointment) => appointment.patientId == patientId),
      isTrue,
    );
  });
}

ProviderContainer _container(_PatientCalendarRepository repository) {
  return ProviderContainer(
    overrides: [
      getPatientAppointmentsUsecaseProvider.overrideWithValue(
        GetPatientAppointmentsUsecase(repository),
      ),
    ],
  );
}

Appointment _appointment(int id, {int patientId = 11}) {
  return Appointment(
    id: id,
    scheduleId: 13,
    patientId: patientId,
    patientName: 'Paciente',
    date: DateTime(2026, 8, 29),
    startTime: '12:30:00',
    status: 'accepted',
    createdAt: DateTime(2026, 8, 29),
    createdBy: 12,
    updatedAt: DateTime(2026, 8, 29),
    updatedBy: 12,
    doctorId: 12,
    doctorName: 'Doctor',
    clinicId: 1,
    clinicName: 'Clinica',
    appointmentDuration: 30,
  );
}

class _PatientCalendarRepository implements AppointmentRepository {
  @override
  Future<void> decideAppointment({
    required int appointmentId,
    required String decision,
  }) => throw UnimplementedError();

  final List<Appointment> initial;
  final refreshCompleter = Completer<List<Appointment>>();
  int calls = 0;

  _PatientCalendarRepository(this.initial);

  @override
  Future<List<Appointment>> getPatientAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    calls++;
    return calls == 1 ? initial : refreshCompleter.future;
  }

  @override
  Future<Appointment> createAppointment({
    required int scheduleId,
    required DateTime date,
    required TimeOfDay startTime,
    required String patientName,
    int? patientId,
    required String status,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Appointment>> getDoctorAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? clientId,
    int? clinicId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Appointment>> getPublicAppointments({
    int? doctorId,
    int? clinicId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Appointment>> getSecretaryAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? doctorId,
    int? clinicId,
    String? status,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> checkRescheduleAvailability({
    required int appointmentId,
    required DateTime date,
    required TimeOfDay startTime,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> rescheduleAppointment({
    required int appointmentId,
    required DateTime date,
    required TimeOfDay startTime,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateAppointmentStatus({
    required int appointmentId,
    required String status,
  }) {
    throw UnimplementedError();
  }
}
