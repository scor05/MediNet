import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/features/clinic/domain/providers/clinic_domain_providers.dart';

/*
-------------------------------------- Notifier -----------------------------------------
*/

class ClientClinicsNotifier extends FamilyAsyncNotifier<List<Clinic>, int> {
  late int _clientId;

  // Estado inicial
  @override
  Future<List<Clinic>> build(int clientId) async {
    _clientId = clientId;
    return _fetch();
  }

  // Método para recargar la lista de clinicas
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<Clinic> createClinic({
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    final clinic = await ref
        .read(createClinicUsecaseProvider)
        .call(name, address, phone, email, _clientId);

    final current = state.asData?.value;
    if (current == null) {
      await refresh();
    } else {
      final updated = [...current, clinic]
        ..sort((a, b) => a.name.compareTo(b.name));
      state = AsyncData(updated);
    }

    return clinic;
  }

  Future<void> deleteClinic(int clinicId) async {
    final previousState = state;

    if (state.hasValue) {
      state = AsyncData(
        state.requireValue.where((clinic) => clinic.id != clinicId).toList(),
      );
    }

    try {
      await ref.read(deleteClinicUsecaseProvider).call(clinicId);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  // Método privado para obtener las clinicas del cliente
  Future<List<Clinic>> _fetch() {
    return ref.read(getClinicsUsecaseProvider).call(_clientId);
  }
}

/*
-------------------------------------- Providers -----------------------------------------
*/

// Provider del notifier
final clientClinicsNotifierProvider =
    AsyncNotifierProvider.family<ClientClinicsNotifier, List<Clinic>, int>(
      ClientClinicsNotifier.new,
    );
