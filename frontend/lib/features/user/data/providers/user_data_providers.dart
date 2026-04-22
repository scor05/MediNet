import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/user/data/datasources/user_remote_datasource.dart';
import 'package:frontend/features/user/data/repositories/user_repository_impl.dart';
import 'package:frontend/features/user/domain/repositories/user_repository.dart';

// Provider para el datasource de horarios
final userRemoteDatasourceProvider = Provider((ref) {
  return UserRemoteDatasource();
});

// Provider para la implementacion del repository de horarios
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.read(userRemoteDatasourceProvider));
});
