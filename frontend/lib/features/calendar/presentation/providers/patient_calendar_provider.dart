import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';

/*
-------------------------------------- Notifier -----------------------------------------
*/

class PatientCalendarNotifier extends AsyncNotifier<List<Appointment>> {
  // Estado inicial
  @override
  Future<List<Appointment>> build() {
    return _fetch(
      ref.watch(patientWeekStartProvider), // Se re-ejecuta si cambia la semana
    );
  }

  // Método privado para obtener las citas del paciente
  Future<List<Appointment>> _fetch(DateTime weekStart) {
    return ref
        .read(getPatientAppointmentsUsecaseProvider)
        .call(
          dateFrom: weekStart,
          dateTo: weekStart.add(const Duration(days: 6)),
        );
  }

  // Método para recargar la lista de citas
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(ref.read(patientWeekStartProvider)),
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
