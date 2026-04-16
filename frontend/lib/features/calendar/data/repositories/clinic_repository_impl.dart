import '../../domain/entities/clinic.dart';
import '../../domain/repositories/clinic_repository.dart';
import '../datasources/clinic_remote_datasource.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'dart:io';
import 'dart:async';

class ClinicRepositoryImpl implements ClinicRepository {
  final ClinicRemoteDatasource datasource;

  ClinicRepositoryImpl(this.datasource);

  @override
  Future<List<Clinic>> getClinics() async {
    try {
      return await datasource.getClinics();
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
  Future<Clinic> createClinic({
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    try {
      return await datasource.createClinic(
        name: name,
        address: address,
        phone: phone,
        email: email,
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
