import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/appointment/data/datasources/appointment_remote_datasource.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDatasource datasource;

  AppointmentRepositoryImpl(this.datasource);

  // Obtiene las citas de un doctor
  @override
  Future<List<Appointment>> getDoctorAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? clientId,
    int? clinicId,
  }) async {
    try {
      return await datasource.getDoctorAppointments(
        dateFrom: dateFrom,
        dateTo: dateTo,
        clientId: clientId,
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

  @override
  Future<List<Appointment>> getSecretaryAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? doctorId,
    int? clinicId,
  }) async {
    try {
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

  // Obtiene las citas de una secretaria
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

  // Crea una cita
  @override
  Future<Appointment> createAppointment({
    required int scheduleId,
    required DateTime date,
    required TimeOfDay startTime,
    required String patientName,
    required String status,
  }) async {
    try {
      return await datasource.createAppointment(
        scheduleId: scheduleId,
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

  // Obtiene las citas públicas de un doctor o clínica
  @override
  Future<List<Appointment>> getPublicAppointments({
    int? doctorId,
    int? clinicId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      return await datasource.getPublicAppointments(
        doctorId: doctorId,
        clinicId: clinicId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    } on TimeoutException {
      throw ApiException('La solicitud tardó demasiado. Intenta de nuevo.');
    } catch (_) {
      throw ApiException('Error inesperado. Intenta de nuevo.');
    }
  }
}
