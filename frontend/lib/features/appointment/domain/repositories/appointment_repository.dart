import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';

abstract class AppointmentRepository {
  // Obtener citas de un doctor
  Future<List<Appointment>> getDoctorAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? clientId,
    int? clinicId,
  });

  // Obtener citas de una secretaria
  Future<List<Appointment>> getSecretaryAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? doctorId,
    int? clinicId,
  });

  // Crear una cita
  Future<Appointment> createAppointment({
    required int scheduleId,
    required DateTime date,
    required TimeOfDay startTime,
    required String patientName,
    required String status,
  });

  // Obtener citas de un paciente
  Future<List<Appointment>> getPatientAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
  });
}
