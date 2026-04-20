import 'package:flutter/foundation.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/usecases/get_secretary_appointments.dart';
import '../../data/datasources/appointment_remote_datasource.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import 'package:frontend/core/exceptions/api_exception.dart';

// ── Estado ────────────────────────────────────────────────────────────────────

class SecretaryCalendarState {
  final DateTime weekStart;
  final List<Appointment> appointments;
  final bool loading;
  final String? error;
  final int? filterDoctorId;
  final int? filterClinicId;

  const SecretaryCalendarState({
    required this.weekStart,
    this.appointments = const [],
    this.loading = true,
    this.error,
    this.filterDoctorId,
    this.filterClinicId,
  });

  SecretaryCalendarState copyWith({
    DateTime? weekStart,
    List<Appointment>? appointments,
    bool? loading,
    String? error,
    Object? filterDoctorId = _sentinel,   
    Object? filterClinicId = _sentinel,
  }) {
    return SecretaryCalendarState(
      weekStart: weekStart ?? this.weekStart,
      appointments: appointments ?? this.appointments,
      loading: loading ?? this.loading,
      error: error,
      filterDoctorId: filterDoctorId == _sentinel
          ? this.filterDoctorId
          : filterDoctorId as int?,
      filterClinicId: filterClinicId == _sentinel
          ? this.filterClinicId
          : filterClinicId as int?,
    );
  }
}

const _sentinel = Object();

//  Notifier 

class SecretaryCalendarNotifier extends ChangeNotifier {
  final GetSecretaryAppointments _usecase;

  SecretaryCalendarNotifier(this._usecase) {
    load();
  }

  late SecretaryCalendarState _state = SecretaryCalendarState(
    weekStart: _getMonday(DateTime.now()),
  );

  SecretaryCalendarState get state => _state;

  DateTime _getMonday(DateTime d) => d.subtract(Duration(days: d.weekday - 1));

  // Navegar semanas
  void previousWeek() {
    _state = _state.copyWith(weekStart: _state.weekStart.subtract(const Duration(days: 7)));
    load();
  }

  void nextWeek() {
    _state = _state.copyWith(weekStart: _state.weekStart.add(const Duration(days: 7)));
    load();
  }

  // Cambiar filtros
  void setDoctorFilter(int? doctorId) {
    _state = _state.copyWith(filterDoctorId: doctorId ?? _sentinel);
    load();
  }

  void setClinicFilter(int? clinicId) {
    _state = _state.copyWith(filterClinicId: clinicId ?? _sentinel);
    load();
  }

  // Añadir cita localmente (retroalimentación inmediata)
  void addAppointment(Appointment a) {
    _state = _state.copyWith(appointments: [..._state.appointments, a]);
    notifyListeners();
    load(); // recarga desde el servidor
  }

  // Carga principal
  Future<void> load() async {
    _state = _state.copyWith(loading: true, error: null);
    notifyListeners();

    try {
      final dateFrom = _state.weekStart;
      final dateTo = _state.weekStart.add(const Duration(days: 6));

      final result = await _usecase(
        dateFrom: dateFrom,
        dateTo: dateTo,
        doctorId: _state.filterDoctorId,
        clinicId: _state.filterClinicId,
      );

      _state = _state.copyWith(appointments: result, loading: false);
    } on ApiException catch (e) {
      _state = _state.copyWith(appointments: [], loading: false, error: e.message);
    } catch (_) {
      _state = _state.copyWith(
        appointments: [],
        loading: false,
        error: 'Ocurrió un error inesperado.',
      );
    }

    notifyListeners();
  }
}

//  Factory helper (para usarlo en la pantalla sin Riverpod) 

SecretaryCalendarNotifier createSecretaryCalendarNotifier() {
  return SecretaryCalendarNotifier(
    GetSecretaryAppointments(
      AppointmentRepositoryImpl(AppointmentRemoteDatasource()),
    ),
  );
}
