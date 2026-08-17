import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/providers/doctor_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/utils/appointment_time_utils.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/user/domain/entities/user.dart';
import 'package:frontend/features/user/domain/providers/user_domain_providers.dart';

class CreateAppointmentFormState {
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
    bool clearError = false,
    bool clearSelectedSchedule = false,
    bool clearSelectedDate = false,
    bool clearSelectedTime = false,
    bool clearPatientResults = false,
    bool clearSelectedPatient = false,
  }) {
    return CreateAppointmentFormState(
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
  Timer? _patientDebounce;
  int _patientRequestId = 0;

  @override
  CreateAppointmentFormState build(DateTime weekStart) {
    ref.onDispose(() => _patientDebounce?.cancel());
    Future.microtask(loadSchedules);

    return const CreateAppointmentFormState(loadingSchedules: true);
  }

  Future<void> loadSchedules() async {
    state = state.copyWith(loadingSchedules: true, clearError: true);

    try {
      final schedules = await ref
          .read(doctorCalendarNotifierProvider.notifier)
          .getDoctorSchedules();

      if (schedules.isEmpty) {
        state = const CreateAppointmentFormState(
          schedules: [],
          loadingSchedules: false,
        );
        return;
      }

      final firstSchedule = schedules.first;
      final selectedDate = nextDayOfWeek(
        weekStart: arg,
        dayOfWeek: firstSchedule.dayOfWeek,
      );
      final timeSlots = buildTimeSlots(firstSchedule);

      state = CreateAppointmentFormState(
        schedules: schedules,
        selectedSchedule: firstSchedule,
        selectedDate: selectedDate,
        timeSlots: timeSlots,
        selectedTime: timeSlots.isNotEmpty ? timeSlots.first : null,
        loadingSchedules: false,
      );
    } catch (e) {
      state = CreateAppointmentFormState(
        schedules: const [],
        loadingSchedules: false,
        error: e is ApiException ? e.message : 'Ocurrió un error inesperado.',
      );
    }
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

  void clearError() {
    state = state.copyWith(clearError: true);
  }

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

  Future<Appointment?> submit({required String patientName}) async {
    final selectedSchedule = state.selectedSchedule;
    final selectedDate = state.selectedDate;
    final selectedTime = state.selectedTime;

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
