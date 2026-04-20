import 'dart:io';
import 'dart:async';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/superadmin/domain/entities/user.dart';
import 'package:frontend/features/superadmin/domain/repositories/user_repository.dart';
import 'package:frontend/features/superadmin/data/datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource datasource;

  UserRepositoryImpl(this.datasource);

  @override
  Future<List<User>> getClientUsers(int clientId) async {
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

  @override
  Future<void> addUserToClient(
    int clientId,
    int userId,
    int role,
    bool isAdmin,
  ) async {
    try {
      await datasource.addUserToClient(clientId, userId, role, isAdmin);
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
  Future<void> updateClientUserAdminPrivileges(
    int clientId,
    int userId,
    int role,
    bool isAdmin,
    bool isActive,
  ) async {
    try {
      await datasource.updateClientUserAdminPrivileges(
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

  @override
  Future<List<User>> getAvailableUsersForClient(
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
}
