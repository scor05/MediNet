import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/superadmin/data/datasources/user_remote_datasource.dart';
import 'package:frontend/features/superadmin/data/repositories/user_repository_impl.dart';
import 'package:frontend/features/superadmin/domain/entities/user.dart';
import 'package:frontend/features/superadmin/domain/repositories/user_repository.dart';
import 'package:frontend/features/superadmin/domain/usecases/get_client_users_usecase.dart';

final organizationUserRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(UserRemoteDatasource());
});

final getOrganizationUsersUsecaseProvider = Provider<GetClientUsersUsecase>((
  ref,
) {
  return GetClientUsersUsecase(ref.read(organizationUserRepositoryProvider));
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

  Future<List<User>> _fetch() {
    return ref.read(getOrganizationUsersUsecaseProvider).call(_clientId);
  }
}

final organizationUsersNotifierProvider =
    AsyncNotifierProvider.family<OrganizationUsersNotifier, List<User>, int>(
      OrganizationUsersNotifier.new,
    );
