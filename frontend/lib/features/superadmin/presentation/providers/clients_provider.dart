import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/client_remote_datasource.dart';
import '../../data/repositories/client_repository_impl.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../../domain/usecases/get_clients_usecase.dart';
import '../../domain/usecases/toggle_client_status_usecase.dart';
import '../../domain/usecases/edit_client_usecase.dart';

// ── Repositorio y usecases ───────────────────────────────────────────────────

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepositoryImpl(ClientRemoteDatasource());
});

final getClientsUsecaseProvider = Provider<GetClientsUsecase>((ref) {
  return GetClientsUsecase(ref.read(clientRepositoryProvider));
});

final toggleClientStatusUsecaseProvider = Provider<ToggleClientStatusUseCase>((
  ref,
) {
  return ToggleClientStatusUseCase(ref.read(clientRepositoryProvider));
});

final editClientUsecaseProvider = Provider<EditClientUsecase>((ref) {
  return EditClientUsecase(ref.read(clientRepositoryProvider));
});

// Provee los filtros de los clientes (null = todos, true = activos, false = inactivos)
final clientFilterProvider = StateProvider<bool?>((ref) => null);

// ── Notifier ──────────────────────────────────────────────────────────────────

class ClientsNotifier extends AsyncNotifier<List<Client>> {
  @override
  Future<List<Client>> build() async {
    return _fetchClients();
  }

  // Recarga la lista completa de clientes desde el servidor
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchClients);
  }

  // Activa o desactiva un cliente y actualiza la lista en memoria
  Future<void> toggleStatus(int clientId) async {
    final current = state.requireValue.firstWhere((c) => c.id == clientId);
    final previousState = state;

    // Optimistic update
    state = AsyncData(
      state.requireValue
          .map((c) => c.id == clientId ? c.copyWith(isActive: !c.isActive) : c)
          .toList(),
    );

    try {
      final updated = await ref
          .read(toggleClientStatusUsecaseProvider)
          .call(clientId: clientId, isActive: !current.isActive);

      state = AsyncData(
        state.requireValue
            .map((c) => c.id == updated.id ? updated : c)
            .toList(),
      );
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  // Edita un cliente y actualiza la lista en memoria
  Future<void> editClient(
    int clientId, {
    required String name,
    required String nit,
  }) async {
    final previousState = state;

    // Optimistic update
    state = AsyncData(
      state.requireValue
          .map((c) => c.id == clientId ? c.copyWith(name: name, nit: nit) : c)
          .toList(),
    );

    try {
      final updated = await ref
          .read(editClientUsecaseProvider)
          .call(clientId: clientId, name: name, nit: nit);

      state = AsyncData(
        state.requireValue
            .map((c) => c.id == updated.id ? updated : c)
            .toList(),
      );
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  /*
  HELPERS
  */

  // Método privado para obtener los clientes
  Future<List<Client>> _fetchClients() async {
    final getClients = ref.read(getClientsUsecaseProvider);
    return getClients();
  }
}

// Provider para el notifier
final clientsNotifierProvider =
    AsyncNotifierProvider<ClientsNotifier, List<Client>>(() {
      return ClientsNotifier();
    });

// Provider derivado que combina la lista con el filtro activo.
final filteredClientsProvider = Provider<AsyncValue<List<Client>>>((ref) {
  final clientsAsync = ref.watch(clientsNotifierProvider);
  final filter = ref.watch(clientFilterProvider);

  return clientsAsync.whenData((clients) {
    if (filter == null) return clients;
    return clients.where((c) => c.isActive == filter).toList();
  });
});
