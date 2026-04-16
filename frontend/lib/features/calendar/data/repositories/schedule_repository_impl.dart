import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_datasource.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'dart:io';
import 'dart:async';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDatasource datasource;

  ScheduleRepositoryImpl(this.datasource);

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

  @override
  Future<Schedule> createSchedule({
    required int idClinic,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required int duration,
  }) async {
    try {
      return await datasource.createSchedule(
        idClinic: idClinic,
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
