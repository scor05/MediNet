import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/repositories/appointment_repository.dart';

class CreateAppointmentUsecase {
  final AppointmentRepository repository;

  CreateAppointmentUsecase(this.repository);

  // Crea una cita
  Future<Appointment> call({
    required int scheduleId,
    required DateTime date,
    required TimeOfDay startTime,
    required String patientName,
    required String status,
  }) async {
    return await repository.createAppointment(
      scheduleId: scheduleId,
      date: date,
      startTime: startTime,
      patientName: patientName,
      status: status,
    );
  }
}
