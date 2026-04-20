import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/superadmin/domain/usecases/get_available_users_for_client.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/get_client_users_usecase.dart';
import '../../domain/usecases/add_user_to_client_usecase.dart';
import '../../domain/entities/user.dart';

// ── Repositorio y usecases ────────────────────────────────────────────────────

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(UserRemoteDatasource());
});

final getClientUsersUsecaseProvider = Provider<GetClientUsersUsecase>((ref) {
  return GetClientUsersUsecase(ref.read(userRepositoryProvider));
});

final addUserToClientUsecaseProvider = Provider<AddUserToClientUsecase>((ref) {
  return AddUserToClientUsecase(ref.read(userRepositoryProvider));
});

final searchAvailableUsersUsecaseProvider =
    Provider<GetAvailableUsersForClient>((ref) {
      return GetAvailableUsersForClient(ref.read(userRepositoryProvider));
    });

// Se devuelve una lista de usuarios disponibles para ser agregados al cliente
final availableUsersProvider =
    FutureProvider.family<List<User>, ({int clientId, String search})>((
      ref,
      params,
    ) async {
      if (params.search.length < 2) return [];
      return ref
          .read(searchAvailableUsersUsecaseProvider)
          .call(params.clientId, params.search);
    });

// ── Notifier de la lista de usuarios del cliente ──────────────────────────────

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

  Future<void> addUser(int userId, String role, bool isAdmin) async {
    try {
      await ref
          .read(addUserToClientUsecaseProvider)
          .call(_clientId, userId, role, isAdmin);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> _fetch() {
    return ref.read(getClientUsersUsecaseProvider).call(_clientId);
  }
}

final clientUsersNotifierProvider =
    AsyncNotifierProvider.family<ClientUsersNotifier, List<User>, int>(
      ClientUsersNotifier.new,
    );
