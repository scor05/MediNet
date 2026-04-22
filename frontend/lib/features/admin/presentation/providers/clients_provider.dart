import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/client/domain/entities/client.dart';
import 'package:frontend/features/client/domain/providers/client_domain_providers.dart';

/*
-------------------------------------- Notifier -----------------------------------------
*/

class ClientsNotifier extends AsyncNotifier<List<Client>> {
  // Estado inicial
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

  // Crea un cliente y actualiza la lista en memoria
  Future<void> createClient({
    required String name,
    required String nit,
    int? userId,
  }) async {
    final newClient = await ref
        .read(createClientUsecaseProvider)
        .call(name: name, nit: nit, userId: userId);

    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, newClient]);
    await refresh();
  }

  // Método privado para obtener los clientes
  Future<List<Client>> _fetchClients() async {
    final getClients = ref.read(getClientsUsecaseProvider);
    return getClients();
  }
}

/*
-------------------------------------- Providers -----------------------------------------
*/

// Provee los filtros de los clientes (null = todos, true = activos, false = inactivos)
final clientFilterProvider = StateProvider<bool?>((ref) => null);

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
