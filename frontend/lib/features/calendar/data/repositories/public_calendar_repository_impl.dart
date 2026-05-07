import 'dart:async';
import 'dart:io';

import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/calendar/data/datasources/public_calendar_remote_datasource.dart';
import 'package:frontend/features/calendar/domain/entities/public_slot.dart';
import 'package:frontend/features/calendar/domain/repositories/public_calendar_repository.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/features/user/domain/entities/user.dart';

class PublicCalendarRepositoryImpl implements PublicCalendarRepository {
  final PublicCalendarRemoteDatasource datasource;

  PublicCalendarRepositoryImpl(this.datasource);

  @override
  Future<List<User>> getDoctors({int? clinicId}) async {
    try {
      return await datasource.getDoctors(clinicId: clinicId);
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
  Future<List<Clinic>> getClinics({int? doctorId}) async {
    try {
      return await datasource.getClinics(doctorId: doctorId);
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
  Future<List<PublicSlot>> getSlots({
    required int doctorId,
    required int clinicId,
    required DateTime date,
  }) async {
    try {
      return await datasource.getSlots(
        doctorId: doctorId,
        clinicId: clinicId,
        date: date,
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
