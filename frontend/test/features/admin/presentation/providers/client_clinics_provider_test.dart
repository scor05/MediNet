import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/presentation/providers/client_clinics_provider.dart';
import 'package:frontend/features/clinic/data/providers/clinic_data_providers.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/features/clinic/domain/repositories/clinic_repository.dart';

void main() {
  test('creates a clinic with the currently selected client id', () async {
    final repository = _RecordingClinicRepository();
    final container = ProviderContainer(
      overrides: [clinicRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(clientClinicsNotifierProvider(27).future);
    await container
        .read(clientClinicsNotifierProvider(27).notifier)
        .createClinic(
          name: 'Clínica Nueva',
          address: 'Zona 10',
          phone: '2222-1111',
          email: 'nueva@example.com',
        );

    expect(repository.createdForClientId, 27);
  });
}

class _RecordingClinicRepository implements ClinicRepository {
  int? createdForClientId;

  Clinic get clinic => Clinic(
    id: 1,
    name: 'Clínica Nueva',
    address: 'Zona 10',
    phone: '2222-1111',
    email: 'nueva@example.com',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    isActive: true,
  );

  @override
  Future<Clinic> createClinic({
    required String name,
    required String address,
    required String phone,
    required String email,
    required int clientId,
  }) async {
    createdForClientId = clientId;
    return clinic;
  }

  @override
  Future<void> deleteClinic(int clinicId) async {}

  @override
  Future<List<Clinic>> getClinics(int? clientId) async => const [];

  @override
  Future<Clinic> updateClinic({
    required int clinicId,
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async => clinic;
}
