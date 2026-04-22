import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/client/data/datasources/client_remote_datasource.dart';
import 'package:frontend/features/client/data/repositories/client_repository_impl.dart';
import 'package:frontend/features/client/domain/repositories/client_repository.dart';

// Provider para el datasource de clientes
final clientRemoteDatasourceProvider = Provider((ref) {
  return ClientRemoteDatasource();
});

// Provider para la implementacion del repository de clientes
final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepositoryImpl(ref.read(clientRemoteDatasourceProvider));
});
