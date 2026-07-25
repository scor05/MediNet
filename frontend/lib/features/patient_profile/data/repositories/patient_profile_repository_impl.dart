import 'dart:async';
import 'dart:io';

import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/patient_profile/data/datasources/patient_profile_remote_datasource.dart';
import 'package:frontend/features/patient_profile/domain/entities/patient_profile.dart';
import 'package:frontend/features/patient_profile/domain/repositories/patient_profile_repository.dart';

class PatientProfileRepositoryImpl implements PatientProfileRepository {
  final PatientProfileRemoteDatasource datasource;

  PatientProfileRepositoryImpl(this.datasource);

  @override
  Future<PatientProfile> getPatientProfile() async {
    try {
      return await datasource.getPatientProfile();
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    } on TimeoutException {
      throw ApiException('La solicitud tardó demasiado. Intenta de nuevo.');
    } catch (e) {
      throw ApiException('Error inesperado al cargar el perfil.');
    }
  }

  @override
  Future<PatientProfile> updatePatientProfile({
    String? name,
    String? phone,
  }) async {
    try {
      return await datasource.updatePatientProfile(name: name, phone: phone);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    } on TimeoutException {
      throw ApiException('La solicitud tardó demasiado. Intenta de nuevo.');
    } catch (e) {
      throw ApiException('Error inesperado al actualizar el perfil.');
    }
  }
}
