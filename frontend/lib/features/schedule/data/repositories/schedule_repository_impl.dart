import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/schedule/data/datasources/schedule_remote_datasource.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDatasource datasource;

  ScheduleRepositoryImpl(this.datasource);

  // Se devuelven todos los horarios del doctor logueado
  @override
  Future<List<Schedule>> getDoctorSchedules() async {
    try {
      return await datasource.getDoctorSchedules();
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

  // Se devuelven los horarios de un doctor por ID
  @override
  Future<List<Schedule>> getSchedulesByDoctorId(int doctorId) async {
    try {
      return await datasource.getSchedulesByDoctorId(doctorId);
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
  Future<List<Schedule>> getSecretarySchedules() async {
    try {
      return await datasource.getSecretarySchedules();
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

  // Se crea un horario
  @override
  Future<Schedule> createSchedule({
    int? doctorId,
    required int clinicId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) async {
    try {
      return await datasource.createSchedule(
        doctorId: doctorId,
        clinicId: clinicId,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
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
  Future<Schedule> updateSchedule({
    required int id,
    required int clinicId,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) async {
    try {
      return await datasource.updateSchedule(
        id: id,
        clinicId: clinicId,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
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

  @override
  Future<void> deleteSchedule(int id) async {
    try {
      await datasource.deleteSchedule(id);
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
