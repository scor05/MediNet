import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';

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
  @override
  Future<List<Appointment>> build() {
    final weekStart = ref.watch(publicWeekStartProvider);

    return _fetch(weekStart);
  }

  Future<List<Appointment>> _fetch(DateTime weekStart) {
    return ref
        .read(getPublicAppointmentsUsecaseProvider)
        .call(
          dateFrom: weekStart,
          dateTo: weekStart.add(const Duration(days: 6)),
        );
  }

  Future<void> refresh() async {
    final weekStart = ref.read(publicWeekStartProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(weekStart));
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

final filteredPublicAppointmentsProvider =
    Provider.autoDispose<AsyncValue<List<Appointment>>>((ref) {
      final appointmentsAsync = ref.watch(publicCalendarNotifierProvider);
      final filters = ref.watch(publicCalendarFilterProvider);

      return appointmentsAsync.whenData((appointments) {
        return appointments.where((appointment) {
          final matchesDoctor =
              filters.doctorId == null ||
              appointment.doctorId == filters.doctorId;

          final matchesClinic =
              filters.clinicId == null ||
              appointment.clinicId == filters.clinicId;

          return matchesDoctor && matchesClinic;
        }).toList();
      });
    });
