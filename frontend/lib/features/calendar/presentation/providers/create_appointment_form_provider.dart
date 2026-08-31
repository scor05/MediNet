import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/providers/doctor_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/utils/appointment_time_utils.dart';
import 'package:frontend/features/clinic/domain/entities/clinic_search_result.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/providers/schedule_domain_providers.dart';
import 'package:frontend/features/search/domain/providers/search_domain_providers.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';
import 'package:frontend/features/user/domain/entities/user.dart';
import 'package:frontend/features/user/domain/providers/user_domain_providers.dart';

class CreateAppointmentFormState {
  final List<DoctorSearchResult> doctorResults;
  final List<ClinicSearchResult> clinicResults;

  final DoctorSearchResult? selectedDoctor;
  final ClinicSearchResult? selectedClinic;

  final bool loadingDoctors;
  final bool loadingClinics;

  final List<Schedule> schedules;
  final Schedule? selectedSchedule;

  final DateTime? selectedDate;
  final String? selectedTime;
  final List<String> timeSlots;

  final bool loadingSchedules;

  final List<User> patientResults;
  final User? selectedPatient;
  final bool loadingPatients;

  final bool saving;
  final String? error;

  const CreateAppointmentFormState({
    this.doctorResults = const [],
    this.clinicResults = const [],
    this.selectedDoctor,
    this.selectedClinic,
    this.loadingDoctors = false,
    this.loadingClinics = false,
    this.schedules = const [],
    this.selectedSchedule,
    this.selectedDate,
    this.selectedTime,
    this.timeSlots = const [],
    this.loadingSchedules = false,
    this.patientResults = const [],
    this.selectedPatient,
    this.loadingPatients = false,
    this.saving = false,
    this.error,
  });

  CreateAppointmentFormState copyWith({
    List<DoctorSearchResult>? doctorResults,
    List<ClinicSearchResult>? clinicResults,
    DoctorSearchResult? selectedDoctor,
    ClinicSearchResult? selectedClinic,
    bool? loadingDoctors,
    bool? loadingClinics,
    List<Schedule>? schedules,
    Schedule? selectedSchedule,
    DateTime? selectedDate,
    String? selectedTime,
    List<String>? timeSlots,
    bool? loadingSchedules,
    List<User>? patientResults,
    User? selectedPatient,
    bool? loadingPatients,
    bool? saving,
    String? error,
    bool clearDoctorResults = false,
    bool clearClinicResults = false,
    bool clearSelectedDoctor = false,
    bool clearSelectedClinic = false,
    bool clearSelectedSchedule = false,
    bool clearSelectedDate = false,
    bool clearSelectedTime = false,
    bool clearPatientResults = false,
    bool clearSelectedPatient = false,
    bool clearError = false,
  }) {
    return CreateAppointmentFormState(
      doctorResults: clearDoctorResults
          ? const []
          : doctorResults ?? this.doctorResults,
      clinicResults: clearClinicResults
          ? const []
          : clinicResults ?? this.clinicResults,

      selectedDoctor: clearSelectedDoctor
          ? null
          : selectedDoctor ?? this.selectedDoctor,
      selectedClinic: clearSelectedClinic
          ? null
          : selectedClinic ?? this.selectedClinic,

      loadingDoctors: loadingDoctors ?? this.loadingDoctors,
      loadingClinics: loadingClinics ?? this.loadingClinics,

      schedules: schedules ?? this.schedules,

      selectedSchedule: clearSelectedSchedule
          ? null
          : selectedSchedule ?? this.selectedSchedule,

      selectedDate: clearSelectedDate
          ? null
          : selectedDate ?? this.selectedDate,

      selectedTime: clearSelectedTime
          ? null
          : selectedTime ?? this.selectedTime,

      timeSlots: timeSlots ?? this.timeSlots,

      loadingSchedules: loadingSchedules ?? this.loadingSchedules,

      patientResults: clearPatientResults
          ? const []
          : patientResults ?? this.patientResults,

      selectedPatient: clearSelectedPatient
          ? null
          : selectedPatient ?? this.selectedPatient,

      loadingPatients: loadingPatients ?? this.loadingPatients,
      saving: saving ?? this.saving,

      error: clearError ? null : error ?? this.error,
    );
  }
}

final createAppointmentFormProvider =
    AutoDisposeNotifierProviderFamily<
      CreateAppointmentFormNotifier,
      CreateAppointmentFormState,
      DateTime
    >(CreateAppointmentFormNotifier.new);

class CreateAppointmentFormNotifier
    extends AutoDisposeFamilyNotifier<CreateAppointmentFormState, DateTime> {
  Timer? _doctorDebounce;
  Timer? _clinicDebounce;
  Timer? _patientDebounce;

  int _doctorRequestId = 0;
  int _clinicRequestId = 0;
  int _patientRequestId = 0;

  List<Schedule> _doctorSchedules = [];

  @override
  CreateAppointmentFormState build(DateTime weekStart) {
    ref.onDispose(() {
      _doctorDebounce?.cancel();
      _clinicDebounce?.cancel();
      _patientDebounce?.cancel();
    });

    return const CreateAppointmentFormState();
  }

  // ---------------------------------------------------------------------------
  // DOCTOR
  // ---------------------------------------------------------------------------

  void onDoctorQueryChanged(String query) {
    _doctorDebounce?.cancel();
    _clinicDebounce?.cancel();

    final requestId = ++_doctorRequestId;
    _clinicRequestId++;

    _doctorSchedules = [];

    state = state.copyWith(
      clearSelectedDoctor: true,
      clearSelectedClinic: true,
      clearDoctorResults: true,
      clearClinicResults: true,
      schedules: const [],
      clearSelectedSchedule: true,
      clearSelectedDate: true,
      clearSelectedTime: true,
      timeSlots: const [],
      loadingSchedules: false,
      loadingClinics: false,
      clearError: true,
    );

    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      unawaited(_searchDoctors('', requestId));
      return;
    }

    if (cleanQuery.length < 2) {
      state = state.copyWith(loadingDoctors: false);
      return;
    }

    _doctorDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _searchDoctors(cleanQuery, requestId),
    );
  }

  void showDoctorSuggestions() {
    if (state.selectedDoctor != null) return;

    _doctorDebounce?.cancel();

    final requestId = ++_doctorRequestId;

    unawaited(_searchDoctors('', requestId));
  }

  Future<void> _searchDoctors(String query, int requestId) async {
    state = state.copyWith(loadingDoctors: true, clearError: true);

    try {
      final result = await ref.read(searchUsecaseProvider).call(query);

      if (requestId != _doctorRequestId) return;

      state = state.copyWith(
        doctorResults: result.doctors.take(16).toList(),
        loadingDoctors: false,
      );
    } catch (e) {
      if (requestId != _doctorRequestId) return;

      state = state.copyWith(
        doctorResults: const [],
        loadingDoctors: false,
        error: e is ApiException
            ? e.message
            : 'No se pudieron buscar doctores.',
      );
    }
  }

  Future<void> selectDoctor(DoctorSearchResult doctor) async {
    _doctorDebounce?.cancel();
    _clinicDebounce?.cancel();

    _doctorRequestId++;
    _clinicRequestId++;

    _doctorSchedules = [];

    state = state.copyWith(
      selectedDoctor: doctor,
      clearSelectedClinic: true,
      clearDoctorResults: true,
      clearClinicResults: true,
      schedules: const [],
      clearSelectedSchedule: true,
      clearSelectedDate: true,
      clearSelectedTime: true,
      timeSlots: const [],
      loadingDoctors: false,
      loadingClinics: false,
      loadingSchedules: true,
      clearError: true,
    );

    await loadSchedules();
  }

  void clearDoctor() {
    _doctorDebounce?.cancel();
    _clinicDebounce?.cancel();

    _doctorRequestId++;
    _clinicRequestId++;

    _doctorSchedules = [];

    state = state.copyWith(
      clearSelectedDoctor: true,
      clearSelectedClinic: true,
      clearDoctorResults: true,
      clearClinicResults: true,
      schedules: const [],
      clearSelectedSchedule: true,
      clearSelectedDate: true,
      clearSelectedTime: true,
      timeSlots: const [],
      loadingDoctors: false,
      loadingClinics: false,
      loadingSchedules: false,
      clearError: true,
    );
  }

  // ---------------------------------------------------------------------------
  // CLÍNICA
  // ---------------------------------------------------------------------------

  void onClinicQueryChanged(String query) {
    if (state.selectedDoctor == null) return;

    _clinicDebounce?.cancel();

    final requestId = ++_clinicRequestId;

    state = state.copyWith(
      clearSelectedClinic: true,
      clearClinicResults: true,
      schedules: const [],
      clearSelectedSchedule: true,
      clearSelectedDate: true,
      clearSelectedTime: true,
      timeSlots: const [],
      loadingSchedules: false,
      clearError: true,
    );

    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      unawaited(_searchClinics('', requestId));
      return;
    }

    if (cleanQuery.length < 2) {
      state = state.copyWith(loadingClinics: false);
      return;
    }

    _clinicDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _searchClinics(cleanQuery, requestId),
    );
  }

  void showClinicSuggestions() {
    if (state.selectedDoctor == null) return;
    if (state.selectedClinic != null) return;

    _clinicDebounce?.cancel();

    final requestId = ++_clinicRequestId;

    unawaited(_searchClinics('', requestId));
  }

  Future<void> _searchClinics(String query, int requestId) async {
    state = state.copyWith(loadingClinics: true, clearError: true);

    try {
      final result = await ref.read(searchUsecaseProvider).call(query);

      if (requestId != _clinicRequestId) return;

      final allowedClinicNames = _doctorSchedules
          .map((schedule) => schedule.clinicName.toLowerCase())
          .toSet();

      final clinics = result.clinics
          .where(
            (clinic) => allowedClinicNames.contains(clinic.name.toLowerCase()),
          )
          .take(16)
          .toList();

      state = state.copyWith(clinicResults: clinics, loadingClinics: false);
    } catch (e) {
      if (requestId != _clinicRequestId) return;

      state = state.copyWith(
        clinicResults: const [],
        loadingClinics: false,
        error: e is ApiException
            ? e.message
            : 'No se pudieron buscar clínicas.',
      );
    }
  }

  void selectClinic(ClinicSearchResult clinic) {
    _clinicDebounce?.cancel();
    _clinicRequestId++;

    final matchingSchedules = _doctorSchedules
        .where(
          (schedule) =>
              schedule.clinicName.toLowerCase() == clinic.name.toLowerCase(),
        )
        .toList();

    state = state.copyWith(
      selectedClinic: clinic,
      clearClinicResults: true,
      loadingClinics: false,
      clearError: true,
    );

    _setSchedules(matchingSchedules);
  }

  void clearClinic() {
    _clinicDebounce?.cancel();
    _clinicRequestId++;

    state = state.copyWith(
      clearSelectedClinic: true,
      clearClinicResults: true,
      schedules: const [],
      clearSelectedSchedule: true,
      clearSelectedDate: true,
      clearSelectedTime: true,
      timeSlots: const [],
      loadingClinics: false,
      loadingSchedules: false,
      clearError: true,
    );
  }

  // ---------------------------------------------------------------------------
  // SCHEDULES
  // ---------------------------------------------------------------------------

  Future<void> loadSchedules() async {
    final doctor = state.selectedDoctor;

    if (doctor == null) {
      state = state.copyWith(schedules: const [], loadingSchedules: false);
      return;
    }

    state = state.copyWith(loadingSchedules: true, clearError: true);

    try {
      _doctorSchedules = await ref
          .read(getSchedulesByDoctorIdUsecaseProvider)
          .call(doctor.id);

      state = state.copyWith(loadingSchedules: false);
    } catch (e) {
      _doctorSchedules = [];

      state = state.copyWith(
        schedules: const [],
        loadingSchedules: false,
        error: e is ApiException
            ? e.message
            : 'No se pudieron cargar los horarios del doctor.',
      );
    }
  }

  void _setSchedules(List<Schedule> schedules) {
    if (schedules.isEmpty) {
      state = state.copyWith(
        schedules: const [],
        clearSelectedSchedule: true,
        clearSelectedDate: true,
        clearSelectedTime: true,
        timeSlots: const [],
        loadingSchedules: false,
        error: 'Este doctor no tiene horarios activos en esta clínica.',
      );

      return;
    }

    final firstSchedule = schedules.first;

    final selectedDate = nextDayOfWeek(
      weekStart: arg,
      dayOfWeek: firstSchedule.dayOfWeek,
    );

    final timeSlots = buildTimeSlots(firstSchedule);

    state = state.copyWith(
      schedules: schedules,
      selectedSchedule: firstSchedule,
      selectedDate: selectedDate,
      timeSlots: timeSlots,
      selectedTime: timeSlots.isNotEmpty ? timeSlots.first : null,
      loadingSchedules: false,
      clearError: true,
    );
  }

  void selectSchedule(Schedule? schedule) {
    if (schedule == null) return;

    final selectedDate = nextDayOfWeek(
      weekStart: arg,
      dayOfWeek: schedule.dayOfWeek,
    );

    final timeSlots = buildTimeSlots(schedule);

    state = state.copyWith(
      selectedSchedule: schedule,
      selectedDate: selectedDate,
      timeSlots: timeSlots,
      selectedTime: timeSlots.isNotEmpty ? timeSlots.first : null,
      clearError: true,
    );
  }

  void selectTime(String? time) {
    state = state.copyWith(selectedTime: time, clearError: true);
  }

  // ---------------------------------------------------------------------------
  // PACIENTE
  // ---------------------------------------------------------------------------

  void onPatientQueryChanged(String query) {
    _patientDebounce?.cancel();

    final requestId = ++_patientRequestId;

    state = state.copyWith(
      clearSelectedPatient: true,
      clearPatientResults: true,
      loadingPatients: false,
      clearError: true,
    );

    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      unawaited(_searchPatients('', requestId));
      return;
    }

    if (cleanQuery.length < 2) return;

    _patientDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _searchPatients(cleanQuery, requestId),
    );
  }

  void showPatientSuggestions() {
    if (state.selectedPatient != null) return;

    _patientDebounce?.cancel();

    final requestId = ++_patientRequestId;

    unawaited(_searchPatients('', requestId));
  }

  Future<void> _searchPatients(String query, int requestId) async {
    state = state.copyWith(loadingPatients: true, clearError: true);

    try {
      final results = await ref.read(searchPatientsUsecaseProvider).call(query);

      if (requestId != _patientRequestId) return;

      state = state.copyWith(
        patientResults: results.take(16).toList(),
        loadingPatients: false,
      );
    } catch (e) {
      if (requestId != _patientRequestId) return;

      state = state.copyWith(
        clearPatientResults: true,
        loadingPatients: false,
        error: e is ApiException
            ? e.message
            : 'No se pudieron buscar pacientes.',
      );
    }
  }

  void selectPatient(User patient) {
    _patientDebounce?.cancel();
    _patientRequestId++;

    state = state.copyWith(
      selectedPatient: patient,
      clearPatientResults: true,
      loadingPatients: false,
      clearError: true,
    );
  }

  void clearPatient() {
    _patientDebounce?.cancel();
    _patientRequestId++;

    state = state.copyWith(
      clearSelectedPatient: true,
      clearPatientResults: true,
      loadingPatients: false,
      clearError: true,
    );
  }

  // ---------------------------------------------------------------------------
  // SUBMIT
  // ---------------------------------------------------------------------------

  Future<Appointment?> submit({required String patientName}) async {
    final selectedDoctor = state.selectedDoctor;
    final selectedClinic = state.selectedClinic;
    final selectedSchedule = state.selectedSchedule;
    final selectedDate = state.selectedDate;
    final selectedTime = state.selectedTime;

    if (selectedDoctor == null) {
      state = state.copyWith(error: 'Selecciona un doctor.');
      return null;
    }

    if (selectedClinic == null) {
      state = state.copyWith(error: 'Selecciona una clínica.');
      return null;
    }

    if (patientName.trim().isEmpty) {
      state = state.copyWith(error: 'Ingresa el nombre del paciente.');
      return null;
    }

    if (selectedSchedule == null ||
        selectedDate == null ||
        selectedTime == null) {
      state = state.copyWith(error: 'Completa todos los campos requeridos.');
      return null;
    }

    state = state.copyWith(saving: true, clearError: true);

    try {
      final parts = selectedTime.split(':');

      final startTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );

      final created = await ref
          .read(doctorCalendarNotifierProvider.notifier)
          .createAppointment(
            scheduleId: selectedSchedule.id,
            date: selectedDate,
            startTime: startTime,
            patientName: patientName.trim(),
            patientId: state.selectedPatient?.id,
            status: 'accepted',
            duration: selectedSchedule.duration,
          );

      state = state.copyWith(saving: false);

      return created;
    } catch (e) {
      state = state.copyWith(
        saving: false,
        error: e is ApiException ? e.message : 'No se pudo agendar la cita.',
      );

      return null;
    }
  }
}
