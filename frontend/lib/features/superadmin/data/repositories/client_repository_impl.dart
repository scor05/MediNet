import 'dart:io';
import 'dart:async';
import 'package:frontend/core/exceptions/api_exception.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_remote_datasource.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDatasource datasource;

  ClientRepositoryImpl(this.datasource);

  @override
  Future<List<Client>> getClients() async {
    try {
      return await datasource.getClients();
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
  Future<Client> toggleClientStatus(int id, bool isActive) async {
    try {
      return await datasource.toggleClientStatus(id, isActive);
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
