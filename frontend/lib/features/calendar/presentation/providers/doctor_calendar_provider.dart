import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/providers/schedule_domain_providers.dart';
import 'package:frontend/features/schedule_blockade/domain/entities/schedule_blockade.dart';
import 'package:frontend/features/schedule_blockade/domain/providers/schedule_blockade_domain_providers.dart';

/*
-------------------------------------- Notifier -----------------------------------------
*/

class DoctorCalendarNotifier extends AsyncNotifier<List<Appointment>> {
  final _cache = <String, List<Appointment>>{};

  @override
  FutureOr<List<Appointment>> build() {
    final weekStart = ref.watch(doctorWeekStartProvider);
    final key = weekStart.toIso8601String();
    if (_cache.containsKey(key)) return _cache[key]!;
    return _fetch(weekStart).then((data) {
      _cache[key] = data;
      return data;
    });
  }

  Future<List<Appointment>> _fetch(DateTime weekStart) {
    return ref
        .read(getDoctorAppointmentsUsecaseProvider)
        .call(
          dateFrom: weekStart,
          dateTo: weekStart.add(const Duration(days: 6)),
        );
  }

  Future<void> refresh() async {
    final weekStart = ref.read(doctorWeekStartProvider);
    _cache.remove(weekStart.toIso8601String());
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(weekStart));
    state.whenData((data) => _cache[weekStart.toIso8601String()] = data);
  }

  // Crea una cita y la agrega al estado local sin refetch
  Future<Appointment> createAppointment({
    required int scheduleId,
    required DateTime date,
    required TimeOfDay startTime,
    required String patientName,
    required String status,
    required int duration,
  }) async {
    final newAppointment = await ref
        .read(createAppointmentUsecaseProvider)
        .call(
          scheduleId: scheduleId,
          date: date,
          startTime: startTime,
          patientName: patientName,
          status: status,
        );
    final withDuration = newAppointment.copyWith(appointmentDuration: duration);
    addAppointment(withDuration);
    return withDuration;
  }

  // Agrega una cita al estado local sin refetch
  void addAppointment(Appointment appointment) {
    final current = state.asData?.value;
    if (current == null) return;
    final updated = [...current, appointment]
      ..sort((a, b) {
        final d = a.date.compareTo(b.date);
        return d != 0 ? d : a.startTime.compareTo(b.startTime);
      });
    _cache[ref.read(doctorWeekStartProvider).toIso8601String()] = updated;
    state = AsyncData(updated);
  }

  Future<List<Schedule>> getDoctorSchedules() async {
    return ref.read(getDoctorSchedulesUsecaseProvider).call();
  }

  Future<Schedule> createSchedule({
    required int clinicId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) async {
    final newSchedule = await ref
        .read(createScheduleUsecaseProvider)
        .call(
          clinicId: clinicId,
          dayOfWeek: dayOfWeek,
          startTime: startTime,
          endTime: endTime,
          duration: duration,
        );
    await refresh();
    return newSchedule;
  }

  Future<ScheduleBlockade> createBlockade({
    required int scheduleId,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    final blockade = await ref.read(createScheduleBlockadeUsecaseProvider).call(
          scheduleId: scheduleId,
          date: date,
          startTime: startTime,
          endTime: endTime,
        );
    addAppointment(Appointment(
      id: blockade.id,
      scheduleId: blockade.idSchedule,
      patientName: '',
      date: DateTime.parse(blockade.date),
      startTime: blockade.startTime,
      status: 'blockade',
      createdAt: DateTime.now(),
      createdBy: 0,
      updatedAt: DateTime.now(),
      updatedBy: 0,
      doctorId: 0,
      doctorName: '',
      clinicId: 0,
      clinicName: '',
      appointmentDuration: _calcDuration(blockade.startTime, blockade.endTime),
      type: 'blockade',
    ));
    refresh();
    return blockade;
  }

  int _calcDuration(String start, String end) {
    final s = start.split(':');
    final e = end.split(':');
    return (int.parse(e[0]) * 60 + int.parse(e[1])) -
        (int.parse(s[0]) * 60 + int.parse(s[1]));
  }

  Future<void> deleteBlockade(int id) async {
    await ref.read(deleteScheduleBlockadeUsecaseProvider).call(id);
    final current = state.asData?.value;
    if (current != null) {
      state = AsyncData(current.where((a) => a.id != id).toList());
    }
    await refresh();
  }
}

/*
-------------------------------------- Providers -----------------------------------------
*/

// Provider del inicio de la semana
final doctorWeekStartProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return now.subtract(Duration(days: now.weekday - 1));
});

// Provider del notifier
final doctorCalendarNotifierProvider =
    AsyncNotifierProvider<DoctorCalendarNotifier, List<Appointment>>(
      DoctorCalendarNotifier.new,
    );
