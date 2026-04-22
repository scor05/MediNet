import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/client/domain/entities/client_user.dart';
import 'package:frontend/features/client/domain/providers/client_domain_providers.dart';

/*
-------------------------------------- Notifier -----------------------------------------
*/

class ClientUsersNotifier extends FamilyAsyncNotifier<List<ClientUser>, int> {
  late int _clientId;

  // Estado inicial
  @override
  Future<List<ClientUser>> build(int clientId) async {
    _clientId = clientId;
    return _fetch();
  }

  // Método para recargar la lista de usuarios
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  // Método para agregar un usuario al cliente
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

  // Método para editar un usuario
  Future<void> editUser({
    required int userId,
    required String role,
    required bool isAdmin,
    required bool isActiveInClient,
  }) async {
    final previousState = state;

    if (state.hasValue) {
      state = AsyncData(
        state.requireValue
            .map((u) => u.user.id == userId ? u.copyWith(isAdmin: isAdmin) : u)
            .toList(),
      );
    }

    try {
      await ref
          .read(editClientUserUsecaseProvider)
          .call(
            clientId: _clientId,
            userId: userId,
            role: role,
            isAdmin: isAdmin,
            isActive: isActiveInClient,
          );
      await refresh();
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  // Método para obtener los usuarios del cliente
  Future<List<ClientUser>> _fetch() {
    return ref.read(getClientUsersUsecaseProvider).call(_clientId);
  }
}

/*
-------------------------------------- Providers -----------------------------------------
*/

// Se devuelve una lista de usuarios disponibles para ser agregados al cliente
final availableUsersForClientProvider =
    FutureProvider.family<List<ClientUser>, ({int clientId, String search})>((
      ref,
      params,
    ) async {
      return ref
          .read(getAvailableUsersForClientUsecaseProvider)
          .call(params.clientId, params.search);
    });

// Provider del notifier
final clientUsersNotifierProvider =
    AsyncNotifierProvider.family<ClientUsersNotifier, List<ClientUser>, int>(
      ClientUsersNotifier.new,
    );
