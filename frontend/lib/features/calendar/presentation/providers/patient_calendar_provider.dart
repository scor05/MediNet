import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/usecases/get_patient_appointments.dart';
import '../../data/datasources/appointment_remote_datasource.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import 'package:frontend/core/exceptions/api_exception.dart';

// ── Estado ────────────────────────────────────────────────────────────────────

class PatientCalendarState {
  final DateTime weekStart;
  final List<Appointment> appointments;
  final bool loading;
  final String? error;

  const PatientCalendarState({
    required this.weekStart,
    this.appointments = const [],
    this.loading = true,
    this.error,
  });

  PatientCalendarState copyWith({
    DateTime? weekStart,
    List<Appointment>? appointments,
    bool? loading,
    String? error,
  }) {
    return PatientCalendarState(
      weekStart: weekStart ?? this.weekStart,
      appointments: appointments ?? this.appointments,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

// ── Providers de dependencias ─────────────────────────────────────────────────

final _patientAppointmentsUsecaseProvider = Provider<GetPatientAppointments>((ref) {
  return GetPatientAppointments(
    AppointmentRepositoryImpl(AppointmentRemoteDatasource()),
  );
});

// ── Notifier ──────────────────────────────────────────────────────────────────

class PatientCalendarNotifier extends Notifier<PatientCalendarState> {
  DateTime _getMonday(DateTime d) => d.subtract(Duration(days: d.weekday - 1));

  @override
  PatientCalendarState build() {
    Future.microtask(load);
    return PatientCalendarState(weekStart: _getMonday(DateTime.now()));
  }

  void previousWeek() {
    state = state.copyWith(weekStart: state.weekStart.subtract(const Duration(days: 7)));
    load();
  }

  void nextWeek() {
    state = state.copyWith(weekStart: state.weekStart.add(const Duration(days: 7)));
    load();
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final dateFrom = state.weekStart;
      final dateTo = state.weekStart.add(const Duration(days: 6));
      final result = await ref.read(_patientAppointmentsUsecaseProvider)(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      state = state.copyWith(appointments: result, loading: false);
    } on ApiException catch (e) {
      state = state.copyWith(appointments: [], loading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        appointments: [],
        loading: false,
        error: 'Ocurrió un error inesperado.',
      );
    }
  }
}

// ── Provider global ───────────────────────────────────────────────────────────

final patientCalendarProvider =
    NotifierProvider<PatientCalendarNotifier, PatientCalendarState>(
      PatientCalendarNotifier.new,
    );
