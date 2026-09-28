import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/providers/schedule_domain_providers.dart';

class PublicCalendarFilters {
  final int? doctorId;
  final int? clinicId;

  const PublicCalendarFilters({this.doctorId, this.clinicId});

  PublicCalendarFilters copyWith({
    int? doctorId,
    int? clinicId,
    bool clearDoctor = false,
    bool clearClinic = false,
  }) {
    return PublicCalendarFilters(
      doctorId: clearDoctor ? null : doctorId ?? this.doctorId,
      clinicId: clearClinic ? null : clinicId ?? this.clinicId,
    );
  }
}

class PublicCalendarNotifier
    extends AutoDisposeAsyncNotifier<List<Appointment>> {
  final _cache = <String, List<Appointment>>{};

  @override
  FutureOr<List<Appointment>> build() {
    final weekStart = ref.watch(publicWeekStartProvider);
    final filters = ref.watch(publicCalendarFilterProvider);

    final key =
        '${weekStart.toIso8601String()}_${filters.doctorId}_${filters.clinicId}';

    if (_cache.containsKey(key)) return _cache[key]!;

    return _fetch(weekStart, filters).then((data) {
      _cache[key] = data;
      return data;
    });
  }

  Future<List<Appointment>> _fetch(
    DateTime weekStart,
    PublicCalendarFilters filters,
  ) {
    return ref
        .read(getPublicAppointmentsUsecaseProvider)
        .call(
          dateFrom: weekStart,
          dateTo: weekStart.add(const Duration(days: 6)),
          doctorId: filters.doctorId, // 👈
          clinicId: filters.clinicId, // 👈
        );
  }

  Future<void> refresh() async {
    final weekStart = ref.read(publicWeekStartProvider);
    final filters = ref.read(publicCalendarFilterProvider);
    final key =
        '${weekStart.toIso8601String()}_${filters.doctorId}_${filters.clinicId}';
    final previous = state.valueOrNull;

    _cache.remove(key);
    if (previous == null) {
      state = const AsyncLoading();
    } else {
      state = AsyncData(previous);
    }

    try {
      final data = await _fetch(weekStart, filters);
      _cache[key] = data;
      state = AsyncData(data);
    } catch (error, stackTrace) {
      if (previous == null) {
        state = AsyncError(error, stackTrace);
      } else {
        state = AsyncData(previous);
      }
    }
  }
}

class PublicCalendarFilterNotifier
    extends AutoDisposeNotifier<PublicCalendarFilters> {
  @override
  PublicCalendarFilters build() {
    return const PublicCalendarFilters();
  }

  void setInitialFilters({int? doctorId, int? clinicId}) {
    state = PublicCalendarFilters(doctorId: doctorId, clinicId: clinicId);
  }

  void selectDoctor(int? doctorId) {
    state = state.copyWith(doctorId: doctorId, clearDoctor: doctorId == null);
  }

  void selectClinic(int? clinicId) {
    state = state.copyWith(clinicId: clinicId, clearClinic: clinicId == null);
  }
}

final publicWeekStartProvider = StateProvider.autoDispose<DateTime>((ref) {
  final now = DateTime.now();
  return now.subtract(Duration(days: now.weekday - 1));
});

final publicCalendarNotifierProvider =
    AutoDisposeAsyncNotifierProvider<PublicCalendarNotifier, List<Appointment>>(
      PublicCalendarNotifier.new,
    );

final publicCalendarFilterProvider =
    AutoDisposeNotifierProvider<
      PublicCalendarFilterNotifier,
      PublicCalendarFilters
    >(PublicCalendarFilterNotifier.new);

/// Loads schedules for the filtered doctor in the public calendar.
/// Returns empty list when no doctor filter is active.
final publicSchedulesProvider =
    FutureProvider.autoDispose<List<Schedule>>((ref) async {
      final filters = ref.watch(publicCalendarFilterProvider);

      if (filters.doctorId == null) return const [];

      final schedules = await ref
          .read(getSchedulesByDoctorIdUsecaseProvider)
          .call(filters.doctorId!);

      // If a clinic filter is active, only show schedules for that clinic
      if (filters.clinicId != null) {
        return schedules
            .where((s) => s.clinicId == filters.clinicId)
            .toList();
      }

      return schedules;
    });

