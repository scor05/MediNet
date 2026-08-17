import 'dart:async';
import 'dart:io';

import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:frontend/features/waitlist/data/datasources/waitlist_remote_datasource.dart';
import 'package:frontend/features/waitlist/domain/entities/waitlist.dart';
import 'package:frontend/features/waitlist/domain/repositories/waitlist_repository.dart';

class WaitlistRepositoryImpl implements WaitlistRepository {
  final WaitlistRemoteDatasource datasource;
  final GetProfileUsecase getProfileUsecase;

  WaitlistRepositoryImpl(this.datasource, this.getProfileUsecase);

  @override
  Future<List<Waitlist>> getPatientWaitlists() async {
    try {
      final profile = await getProfileUsecase();
      return await datasource.getPatientWaitlists(profile.id);
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
  Future<Waitlist> createWaitlist({
    required int targetAppointmentId,
    required int fallbackAppointmentId,
  }) async {
    try {
      final profile = await getProfileUsecase();
      return await datasource.createWaitlist(
        patientId: profile.id,
        targetAppointmentId: targetAppointmentId,
        fallbackAppointmentId: fallbackAppointmentId,
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
  Future<void> cancelWaitlist({required int waitlistId}) async {
    try {
      await datasource.cancelWaitlist(waitlistId);
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
