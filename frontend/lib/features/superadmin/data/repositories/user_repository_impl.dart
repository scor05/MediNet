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
  Future<List<User>> getUsers(int clientId) async {
    try {
      return await datasource.getUsers(clientId);
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
