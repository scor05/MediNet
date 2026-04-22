import 'dart:io';
import 'dart:async';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/admin/domain/entities/clinic.dart';
import 'package:frontend/features/admin/domain/repositories/clinic_repository.dart';
import 'package:frontend/features/admin/data/datasources/clinic_remote_datasource.dart';

class ClinicRepositoryImpl implements ClinicRepository {
  final ClinicRemoteDatasource datasource;

  ClinicRepositoryImpl(this.datasource);

  @override
  Future<List<Clinic>> getClinics(int clientId) async {
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
}
