import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/patient_profile/data/datasources/patient_profile_remote_datasource.dart';
import 'package:frontend/features/patient_profile/data/repositories/patient_profile_repository_impl.dart';
import 'package:frontend/features/patient_profile/domain/repositories/patient_profile_repository.dart';

// Provider para el datasource del perfil del paciente
final patientProfileRemoteDatasourceProvider = Provider((ref) {
  return PatientProfileRemoteDatasource();
});

// Provider para la implementación del repository del perfil del paciente
final patientProfileRepositoryProvider =
    Provider<PatientProfileRepository>((ref) {
  return PatientProfileRepositoryImpl(
    ref.read(patientProfileRemoteDatasourceProvider),
  );
});
