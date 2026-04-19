import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/clinic_remote_datasource.dart';
import '../../data/repositories/clinic_repository_impl.dart';
import '../../domain/repositories/clinic_repository.dart';
import '../../domain/usecases/get_client_clinics_usecase.dart';
import '../../domain/entities/clinic.dart';

// ── Repositorio y usecase ────────────────────────────────────────────────────

final clinicRepositoryProvider = Provider<ClinicRepository>((ref) {
  return ClinicRepositoryImpl(ClinicRemoteDatasource());
});

final getClientClinicsUsecaseProvider = Provider<GetClientClinicsUsecase>((ref) {
  return GetClientClinicsUsecase(ref.read(clinicRepositoryProvider));
});

// ── Notifier ──────────────────────────────────────────────────────────────────

class ClientClinicsNotifier extends FamilyAsyncNotifier<List<Clinic>, int> {
  late int _clientId;

  @override
  Future<List<Clinic>> build(int clientId) async {
    _clientId = clientId;
    return _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<List<Clinic>> _fetch() {
    return ref.read(getClientClinicsUsecaseProvider).call(_clientId);
  }
}

final clientClinicsNotifierProvider =
    AsyncNotifierProvider.family<ClientClinicsNotifier, List<Clinic>, int>(
  ClientClinicsNotifier.new,
);