import 'dart:async';
import 'dart:io';

import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/client/data/datasources/client_remote_datasource.dart';
import 'package:frontend/features/client/domain/entities/client.dart';
import 'package:frontend/features/client/domain/entities/client_user.dart';
import 'package:frontend/features/client/domain/repositories/client_repository.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDatasource datasource;

  ClientRepositoryImpl(this.datasource);

  /*
  ---------------------------------------- Clientes ---------------------------------------
  */

  // Obtiene todos los clientes
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

  // Cambia el estado de un cliente
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

  // Crea un nuevo cliente
  @override
  Future<Client> createClient({
    required String name,
    required String nit,
    int? userId,
  }) async {
    try {
      return await datasource.createClient(
        name: name,
        nit: nit,
        userId: userId,
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

  // Edita la información de un cliente
  @override
  Future<Client> editClient(
    int id, {
    required String name,
    required String nit,
  }) async {
    try {
      return await datasource.editClient(id, name: name, nit: nit);
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

  /*
  ---------------------------------------- Usuarios de Clientes ---------------------------------------
  */

  // Obtiene los usuarios de un cliente
  @override
  Future<List<ClientUser>> getClientUsers(int clientId) async {
    try {
      return await datasource.getClientUsers(clientId);
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

  // Obtiene los usuarios disponibles para agregar a un cliente
  @override
  Future<List<ClientUser>> getAvailableUsersForClient(
    int clientId,
    String search,
  ) async {
    try {
      return await datasource.getAvailableUsersForClient(clientId, search);
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

  // Agrega un usuario a un cliente
  @override
  Future<ClientUser> addUserToClient(
    int clientId,
    int userId,
    int role,
    bool isAdmin,
  ) async {
    try {
      return await datasource.addUserToClient(clientId, userId, role, isAdmin);
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

  // Edita un usuario de un cliente
  @override
  Future<ClientUser> editClientUser(
    int clientId,
    int userId,
    int role,
    bool isAdmin,
    bool isActive,
  ) async {
    try {
      return await datasource.editClientUser(
        clientId,
        userId,
        role,
        isAdmin,
        isActive,
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
