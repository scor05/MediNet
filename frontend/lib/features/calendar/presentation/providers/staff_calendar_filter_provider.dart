import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

class StaffCalendarFilterState {
  final int? patientId;
  final String? patientName;
  final int? doctorId;
  final String? doctorName;
  final bool filterDoctor;
  final int? clinicId;
  final String? clinicName;
  final bool filterClinic;
  final String? startTime;
  final String? endTime;
  final bool showSchedules;
  final bool showBlockades;
  final bool showAppointments;
  final bool showCancelled;

  const StaffCalendarFilterState({
    this.patientId,
    this.patientName,
    this.doctorId,
    this.doctorName,
    this.filterDoctor = false,
    this.clinicId,
    this.clinicName,
    this.filterClinic = false,
    this.startTime,
    this.endTime,
    this.showSchedules = true,
    this.showBlockades = true,
    this.showAppointments = true,
    this.showCancelled = true,
  });

  bool overlapsTimeRange({
    required int itemStartMinute,
    required int itemEndMinute,
  }) {
    final minimum = _minutes(startTime);
    final maximum = _minutes(endTime);

    if (minimum != null && itemEndMinute <= minimum) return false;
    if (maximum != null && itemStartMinute >= maximum) return false;
    return true;
  }

  static int? _minutes(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

bool appointmentMatchesStaffFilters(
  Appointment appointment,
  StaffCalendarFilterState filters, {
  required bool filterByDoctor,
}) {
  if (!appointment.isBlockade) {
    if (!filters.showAppointments) return false;
    if (!filters.showCancelled && appointment.isCancelled) return false;
    if (filters.patientId != null &&
        appointment.patientId != filters.patientId) {
      return false;
    }
  } else if (!filters.showBlockades) {
    return false;
  }

  if (filterByDoctor &&
      filters.filterDoctor &&
      filters.doctorId != null &&
      appointment.doctorId != filters.doctorId) {
    return false;
  }
  if (filters.filterClinic &&
      filters.clinicId != null &&
      appointment.clinicId != filters.clinicId) {
    return false;
  }

  final start = _timeMinutes(appointment.startTime);
  return filters.overlapsTimeRange(
    itemStartMinute: start,
    itemEndMinute: start + appointment.appointmentDuration,
  );
}

bool scheduleMatchesStaffFilters(
  Schedule schedule,
  StaffCalendarFilterState filters, {
  required bool filterByDoctor,
}) {
  if (!filters.showSchedules) return false;
  if (filterByDoctor &&
      filters.filterDoctor &&
      filters.doctorId != null &&
      schedule.doctorId != filters.doctorId) {
    return false;
  }
  if (filters.filterClinic &&
      filters.clinicId != null &&
      schedule.clinicId != filters.clinicId) {
    return false;
  }
  return filters.overlapsTimeRange(
    itemStartMinute: _timeMinutes(schedule.startTime),
    itemEndMinute: _timeMinutes(schedule.endTime),
  );
}

int _timeMinutes(String time) {
  final parts = time.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

class StaffCalendarFilterNotifier extends Notifier<StaffCalendarFilterState> {
  @override
  StaffCalendarFilterState build() => const StaffCalendarFilterState();

  void setFilters(StaffCalendarFilterState filters) {
    state = filters;
  }

  void clearAll() {
    state = const StaffCalendarFilterState();
  }
}

final doctorCalendarFilterProvider =
    NotifierProvider<StaffCalendarFilterNotifier, StaffCalendarFilterState>(
      StaffCalendarFilterNotifier.new,
    );

final secretaryCalendarFilterProvider =
    NotifierProvider<StaffCalendarFilterNotifier, StaffCalendarFilterState>(
      StaffCalendarFilterNotifier.new,
    );
