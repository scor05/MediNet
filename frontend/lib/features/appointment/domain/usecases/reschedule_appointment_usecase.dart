import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/repositories/appointment_repository.dart';

class RescheduleAppointmentUsecase {
  final AppointmentRepository repository;

  RescheduleAppointmentUsecase(this.repository);

  Future<void> check({
    required int appointmentId,
    required DateTime date,
    required TimeOfDay startTime,
  }) {
    return repository.checkRescheduleAvailability(
      appointmentId: appointmentId,
      date: date,
      startTime: startTime,
    );
  }

  Future<void> call({
    required int appointmentId,
    required DateTime date,
    required TimeOfDay startTime,
  }) {
    return repository.rescheduleAppointment(
      appointmentId: appointmentId,
      date: date,
      startTime: startTime,
    );
  }
}
