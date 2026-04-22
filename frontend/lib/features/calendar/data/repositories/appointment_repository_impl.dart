import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'dart:io';
import 'dart:async';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDatasource datasource;

  AppointmentRepositoryImpl(this.datasource);

  // Obtiene las citas de un doctor
  @override
  Future<List<Appointment>> getDoctorAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      return await datasource.getDoctorAppointments(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    } on TimeoutException {
      throw ApiException('La solicitud tardó demasiado. Intenta de nuevo.');
    } catch (e) {
      throw ApiException('Error inesperado. Intenta de nuevo.');
    }
  }

  @override
  Future<Appointment> createAppointment({
    required int idSchedule,
    required String date,
    required String startTime,
    required String patientName,
    required String status,
  }) async {
    try {
      return await datasource.createAppointment(
        idSchedule: idSchedule,
        date: date,
        startTime: startTime,
        patientName: patientName,
        status: status,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    } on TimeoutException {
      throw ApiException('La solicitud tardó demasiado. Intenta de nuevo.');
    } catch (e) {
      throw ApiException('Error inesperado. Intenta de nuevo.');
    }
  }

  @override
  Future<List<Appointment>> getPatientAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      return await datasource.getPatientAppointments(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    } on TimeoutException {
      throw ApiException('La solicitud tardó demasiado. Intenta de nuevo.');
    } catch (e) {
      throw ApiException('Error inesperado. Intenta de nuevo.');
    }
  }

  @override
  Future<List<Appointment>> getSecretaryAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? doctorId,
    int? clinicId,
  }) async {
    try{
      return await datasource.getSecretaryAppointments(
        dateFrom: dateFrom,
        dateTo: dateTo,
        doctorId: doctorId,
        clinicId: clinicId,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    } on TimeoutException {
      throw ApiException('La solicitud tardó demasiado. Intenta de nuevo.');
    } catch (e) {
      throw ApiException('Error inesperado. Intenta de nuevo.');
    }
  }
}
