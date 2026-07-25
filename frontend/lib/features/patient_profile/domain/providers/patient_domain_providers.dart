import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/patient_profile/data/providers/patient_data_providers.dart';
import 'package:frontend/features/patient_profile/domain/entities/patient_profile.dart';
import 'package:frontend/features/patient_profile/domain/usecases/get_patient_profile_usecase.dart';
import 'package:frontend/features/patient_profile/domain/usecases/update_patient_profile_usecase.dart';

// Provider para el usecase getPatientProfile
final getPatientProfileUsecaseProvider = Provider((ref) {
  return GetPatientProfileUsecase(ref.read(patientProfileRepositoryProvider));
});

// Provider para el usecase updatePatientProfile
final updatePatientProfileUsecaseProvider = Provider((ref) {
  return UpdatePatientProfileUsecase(
    ref.read(patientProfileRepositoryProvider),
  );
});

// AsyncNotifier que expone el perfil del paciente y permite actualizarlo
class PatientProfileNotifier extends AsyncNotifier<PatientProfile> {
  @override
  Future<PatientProfile> build() async {
    return ref.read(getPatientProfileUsecaseProvider)();
  }

  Future<void> updateProfile({String? name, String? phone}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() {
      return ref.read(updatePatientProfileUsecaseProvider)(
        name: name,
        phone: phone,
      );
    });
  }
}

final patientProfileNotifierProvider =
    AsyncNotifierProvider<PatientProfileNotifier, PatientProfile>(() {
  return PatientProfileNotifier();
});
