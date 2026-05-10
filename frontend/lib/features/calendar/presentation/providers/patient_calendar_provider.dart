import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';

/*
-------------------------------------- Notifier -----------------------------------------
*/

class PatientCalendarNotifier extends AsyncNotifier<List<Appointment>> {
  final _cache = <String, List<Appointment>>{};

  @override
  FutureOr<List<Appointment>> build() {
    final weekStart = ref.watch(patientWeekStartProvider);
    final key = weekStart.toIso8601String();
    if (_cache.containsKey(key)) return _cache[key]!;
    return _fetch(weekStart).then((data) {
      _cache[key] = data;
      return data;
    });
  }

  Future<List<Appointment>> _fetch(DateTime weekStart) {
    return ref
        .read(getPatientAppointmentsUsecaseProvider)
        .call(
          dateFrom: weekStart,
          dateTo: weekStart.add(const Duration(days: 6)),
        );
  }

  Future<void> refresh() async {
    final weekStart = ref.read(patientWeekStartProvider);
    _cache.remove(weekStart.toIso8601String());
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(weekStart));
    state.whenData((data) => _cache[weekStart.toIso8601String()] = data);
  }
}

/*
-------------------------------------- Providers -----------------------------------------
*/

// Provider del inicio de la semana
final patientWeekStartProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return now.subtract(Duration(days: now.weekday - 1));
});

// Provider del notifier
final patientCalendarNotifierProvider =
    AsyncNotifierProvider<PatientCalendarNotifier, List<Appointment>>(
      PatientCalendarNotifier.new,
    );
