import 'dart:async';
import 'dart:io';

import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/clinic/data/datasources/clinic_remote_datasource.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/features/clinic/domain/repositories/clinic_repository.dart';

class ClinicRepositoryImpl implements ClinicRepository {
  final ClinicRemoteDatasource datasource;

  ClinicRepositoryImpl(this.datasource);

  // Obtiene las clínicas de un cliente
  @override
  Future<List<Clinic>> getClinics(int? clientId) async {
    try {
      return await datasource.getClinics(clientId);
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

  // Crea una nueva clínica
  @override
  Future<Clinic> createClinic({
    required String name,
    required String address,
    required String phone,
    required String email,
    required int clientId,
  }) async {
    try {
      return await datasource.createClinic(
        name: name,
        address: address,
        phone: phone,
        email: email,
        clientId: clientId,
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
