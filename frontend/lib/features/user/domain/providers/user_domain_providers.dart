import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/user/data/providers/user_data_providers.dart';
import 'package:frontend/features/user/domain/entities/patient_profile.dart';
import 'package:frontend/features/user/domain/usecases/get_available_users_usecase.dart';
import 'package:frontend/features/user/domain/usecases/get_patient_profile_usecase.dart';
import 'package:frontend/features/user/domain/usecases/save_fcm_token_usecase.dart';

// Provider para el usecase getAvailableUsers
final getAvailableUsersUsecaseProvider = Provider((ref) {
  return GetAvailableUsersUsecase(ref.read(userRepositoryProvider));
});

// Provider para guardar el token FCM
final saveFcmTokenUsecaseProvider = Provider((ref) {
  return SaveFcmTokenUsecase(ref.read(userRepositoryProvider));
});

// Provider para el usecase getPatientProfile
final getPatientProfileUsecaseProvider = Provider((ref) {
  return GetPatientProfileUsecase(ref.read(userRepositoryProvider));
});

// FutureProvider autodispose para consultar el perfil del paciente
final patientProfileFutureProvider = FutureProvider.autoDispose<PatientProfile>((ref) {
  return ref.read(getPatientProfileUsecaseProvider).call();
});
