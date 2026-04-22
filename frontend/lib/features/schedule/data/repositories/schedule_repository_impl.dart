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

  // Se crea un horario
  @override
  Future<Schedule> createSchedule({
    required int clinicId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) async {
    try {
      return await datasource.createSchedule(
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
}
