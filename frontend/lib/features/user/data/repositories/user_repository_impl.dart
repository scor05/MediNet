import 'dart:async';
import 'dart:io';

import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/user/data/datasources/user_remote_datasource.dart';
import 'package:frontend/features/user/domain/entities/patient_profile.dart';
import 'package:frontend/features/user/domain/entities/user.dart';
import 'package:frontend/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource datasource;

  UserRepositoryImpl(this.datasource);

  @override
  Future<List<User>> searchPatients(String search) async {
    try {
      return await datasource.searchPatients(search);
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

  // Obtiene el perfil básico del paciente autenticado
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
      throw ApiException('Error inesperado. Intenta de nuevo.');
    }
  }

  // Obtiene usuarios que no son superadmin
  @override
  Future<List<User>> getAvailableUsers(String search) async {
    try {
      return await datasource.getAvailableUsers(search);
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

  // Guarda el token FCM del usuario
  @override
  Future<void> saveFcmToken() async {
    try {
      await datasource.saveFcmToken();
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
