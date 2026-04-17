import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/client_remote_datasource.dart';
import '../../data/repositories/client_repository_impl.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../../domain/usecases/get_clients_usecase.dart';
import '../../domain/usecases/toggle_client_status_usecase.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepositoryImpl(ClientRemoteDatasource());
});

final getClientsUseCaseProvider = Provider<GetClientsUseCase>((ref) {
  final repository = ref.read(clientRepositoryProvider);
  return GetClientsUseCase(repository);
});

final toggleClientStatusUseCaseProvider = Provider<ToggleClientStatusUseCase>((
  ref,
) {
  final repository = ref.read(clientRepositoryProvider);
  return ToggleClientStatusUseCase(repository);
});

// Provee los filtros de los clientes (null = todos, true = activos, false = inactivos)
final clientFilterProvider = StateProvider<bool?>((ref) => null);

// Notifier que maneja los 3 estados (loading / data / error) automáticamente
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
  Future<void> toggleStatus(Client client) async {
    final toggleClientStatus = ref.read(toggleClientStatusUseCaseProvider);

    // Guardamos la lista actual para poder revertir si falla
    final previousState = state;

    // Actualizamos la UI antes de que responda el servidor
    state = AsyncData(
      state.requireValue.map((c) {
        return c.id == client.id ? c.copyWith(isActive: !c.isActive) : c;
      }).toList(),
    );

    try {
      final updated = await toggleClientStatus(
        clientId: client.id,
        isActive: !client.isActive,
      );

      // Se confirma la lista de clientes con el valor real que devolvió el servidor
      state = AsyncData(
        state.requireValue.map((c) {
          return c.id == updated.id ? updated : c;
        }).toList(),
      );
    } catch (e) {
      // Si falla, revertimos al estado anterior
      state = previousState;
      rethrow;
    }
  }

  /*
  HELPERS
  */

  // Método privado para obtener los clientes
  Future<List<Client>> _fetchClients() async {
    final getClients = ref.read(getClientsUseCaseProvider);
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
