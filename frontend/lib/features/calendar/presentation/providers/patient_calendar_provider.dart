import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';

/*
-------------------------------------- Notifier -----------------------------------------
*/

class PatientCalendarNotifier extends AsyncNotifier<List<Appointment>> {
  final _cache = <String, List<Appointment>>{};
  int _refreshToken = 0;

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
    await _refresh(weekStart);
  }

  Future<void> refreshAll() async {
    final weekStart = ref.read(patientWeekStartProvider);
    final currentKey = weekStart.toIso8601String();
    _cache.removeWhere((key, _) => key != currentKey);
    await _refresh(weekStart);
  }

  Future<void> _refresh(DateTime weekStart) async {
    final key = weekStart.toIso8601String();
    final previousData = state.asData?.value ?? _cache[key];
    final refreshToken = ++_refreshToken;

    state = previousData == null
        ? const AsyncLoading()
        : const AsyncLoading<List<Appointment>>().copyWithPrevious(
            AsyncData(previousData),
          );

    final result = await AsyncValue.guard(() => _fetch(weekStart));
    if (refreshToken != _refreshToken) return;
    final isCurrentWeek =
        ref.read(patientWeekStartProvider).toIso8601String() == key;

    result.when(
      data: (data) {
        _cache[key] = data;
        if (isCurrentWeek) state = AsyncData(data);
      },
      error: (error, stackTrace) {
        if (!isCurrentWeek) return;
        state = previousData == null
            ? AsyncError(error, stackTrace)
            : AsyncData(previousData);
      },
      loading: () {},
    );
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
