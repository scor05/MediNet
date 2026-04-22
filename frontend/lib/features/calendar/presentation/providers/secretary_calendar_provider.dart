import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/providers/schedule_domain_providers.dart';

/*
-------------------------------------- Notifier -----------------------------------------
*/

class DoctorCalendarNotifier extends AsyncNotifier<List<Appointment>> {
  // Estado inicial
  @override
  Future<List<Appointment>> build() {
    return _fetch(
      ref.watch(weekStartProvider), // Se re-ejecuta si cambia la semana
    );
  }

  // Método privado para obtener las citas del doctor
  Future<List<Appointment>> _fetch(DateTime weekStart) {
    return ref
        .read(getSecretaryAppointmentsUsecaseProvider)
        .call(
          dateFrom: weekStart,
          dateTo: weekStart.add(const Duration(days: 6)),
        );
  }

  // Método para recargar la lista de citas
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(ref.read(weekStartProvider)));
  }

  // Método para agregar una cita de forma optimista (Se actualiza la UI antes de obtener la respuesta del backend)
  Future<Appointment> createAppointment({
    required int scheduleId,
    required DateTime date,
    required TimeOfDay startTime,
    required String patientName,
    required String status,
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
    await refresh();
    return newAppointment;
  }

  // Método para obtener los horarios del doctor
  Future<List<Schedule>> getDoctorSchedules() async {
    return ref.read(getDoctorSchedulesUsecaseProvider).call();
  }

  // Método para crear un horario de forma optimista (Se actualiza la UI antes de obtener la respuesta del backend)
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
final weekStartProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return now.subtract(Duration(days: now.weekday - 1));
});

// Provider del notifier
final doctorCalendarNotifierProvider =
    AsyncNotifierProvider<DoctorCalendarNotifier, List<Appointment>>(
      DoctorCalendarNotifier.new,
    );
