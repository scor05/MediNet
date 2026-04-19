import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/get_client_users_usecase.dart';
import '../../domain/entities/user.dart';

// ── Repositorio y usecase ────────────────────────────────────────────────────

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(UserRemoteDatasource());
});

final getClientUsersUsecaseProvider = Provider<GetClientUsersUsecase>((ref) {
  return GetClientUsersUsecase(ref.read(userRepositoryProvider));
});

// ── Notifier ──────────────────────────────────────────────────────────────────

class ClientUsersNotifier extends FamilyAsyncNotifier<List<User>, int> {
  late int _clientId;

  @override
  Future<List<User>> build(int clientId) async {
    _clientId = clientId;
    return _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<List<User>> _fetch() {
    return ref.read(getClientUsersUsecaseProvider).call(_clientId);
  }
}

final clientUsersNotifierProvider =
    AsyncNotifierProvider.family<ClientUsersNotifier, List<User>, int>(
  ClientUsersNotifier.new,
);