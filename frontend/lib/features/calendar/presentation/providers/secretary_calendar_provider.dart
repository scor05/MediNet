import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/providers/schedule_domain_providers.dart';

/*
-------------------------------------- Notifier -----------------------------------------
*/

class SecretaryCalendarNotifier extends AsyncNotifier<List<Appointment>> {
  final _cache = <String, List<Appointment>>{};

  @override
  FutureOr<List<Appointment>> build() {
    final weekStart = ref.watch(secretaryWeekStartProvider);
    final key = weekStart.toIso8601String();
    if (_cache.containsKey(key)) return _cache[key]!;
    return _fetch(weekStart).then((data) {
      _cache[key] = data;
      return data;
    });
  }

  Future<List<Appointment>> _fetch(DateTime weekStart) {
    return ref
        .read(getSecretaryAppointmentsUsecaseProvider)
        .call(
          dateFrom: weekStart,
          dateTo: weekStart.add(const Duration(days: 6)),
        );
  }

  Future<void> refresh() async {
    final weekStart = ref.read(secretaryWeekStartProvider);
    _cache.remove(weekStart.toIso8601String());
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(weekStart));
    state.whenData((data) => _cache[weekStart.toIso8601String()] = data);
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
    _cache[ref.read(secretaryWeekStartProvider).toIso8601String()] = updated;
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
}

/*
-------------------------------------- Providers -----------------------------------------
*/

// Provider del inicio de la semana
final secretaryWeekStartProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return now.subtract(Duration(days: now.weekday - 1));
});

// Provider del notifier
final secretaryCalendarNotifierProvider =
    AsyncNotifierProvider<SecretaryCalendarNotifier, List<Appointment>>(
      SecretaryCalendarNotifier.new,
    );
