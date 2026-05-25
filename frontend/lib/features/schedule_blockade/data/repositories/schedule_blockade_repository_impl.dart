import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/schedule_blockade/data/datasources/schedule_blockade_remote_datasource.dart';
import 'package:frontend/features/schedule_blockade/domain/entities/schedule_blockade.dart';
import 'package:frontend/features/schedule_blockade/domain/repositories/schedule_blockade_repository.dart';

class ScheduleBlockadeRepositoryImpl implements ScheduleBlockadeRepository {
  final ScheduleBlockadeRemoteDatasource datasource;

  ScheduleBlockadeRepositoryImpl(this.datasource);

  @override
  Future<ScheduleBlockade> createBlockade({
    required int scheduleId,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    try {
      return await datasource.createBlockade(
        scheduleId: scheduleId,
        date: date,
        startTime: startTime,
        endTime: endTime,
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
  Future<void> deleteBlockade(int id) async {
    try {
      await datasource.deleteBlockade(id);
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
