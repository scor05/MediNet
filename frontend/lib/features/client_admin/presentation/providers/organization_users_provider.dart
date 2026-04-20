import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/superadmin/data/datasources/user_remote_datasource.dart';
import 'package:frontend/features/superadmin/data/repositories/user_repository_impl.dart';
import 'package:frontend/features/superadmin/domain/entities/user.dart';
import 'package:frontend/features/superadmin/domain/repositories/user_repository.dart';
import 'package:frontend/features/superadmin/domain/usecases/get_client_users_usecase.dart';
import 'package:frontend/features/superadmin/domain/usecases/update_client_user_admin_usecase.dart';

final organizationUserRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(UserRemoteDatasource());
});

final getOrganizationUsersUsecaseProvider = Provider<GetClientUsersUsecase>((
  ref,
) {
  return GetClientUsersUsecase(ref.read(organizationUserRepositoryProvider));
});

final updateOrganizationUserAdminUsecaseProvider =
    Provider<UpdateClientUserAdminUsecase>((ref) {
      return UpdateClientUserAdminUsecase(
        ref.read(organizationUserRepositoryProvider),
      );
    });

class OrganizationUsersNotifier extends FamilyAsyncNotifier<List<User>, int> {
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

  Future<void> updateAdminPrivileges({
    required int userId,
    required String role,
    required bool isAdmin,
    required bool isActiveInClient,
  }) async {
    final previousState = state;

    if (state.hasValue) {
      state = AsyncData(
        state.requireValue
            .map(
              (user) =>
                  user.id == userId ? user.copyWith(isAdmin: isAdmin) : user,
            )
            .toList(),
      );
    }

    try {
      await ref
          .read(updateOrganizationUserAdminUsecaseProvider)
          .call(
            clientId: _clientId,
            userId: userId,
            role: _mapRole(role),
            isAdmin: isAdmin,
            isActive: isActiveInClient,
          );
      await refresh();
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<List<User>> _fetch() {
    return ref.read(getOrganizationUsersUsecaseProvider).call(_clientId);
  }

  int _mapRole(String role) {
    switch (role) {
      case 'Administrador':
        return 0;
      case 'Doctor':
        return 1;
      case 'Secretaria':
        return 2;
      default:
        throw ArgumentError('Rol no soportado: $role');
    }
  }
}

final organizationUsersNotifierProvider =
    AsyncNotifierProvider.family<OrganizationUsersNotifier, List<User>, int>(
      OrganizationUsersNotifier.new,
    );
