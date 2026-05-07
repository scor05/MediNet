import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/data/datasources/appointment_remote_datasource.dart';
import 'package:frontend/features/appointment/data/repositories/appointment_repository_impl.dart';
import 'package:frontend/features/appointment/domain/repositories/appointment_repository.dart';

// Provider para el datasource de citas
final appointmentRemoteDatasourceProvider = Provider((ref) {
  return AppointmentRemoteDatasource();
});

// Provider para la implementacion del repository de citas
final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepositoryImpl(
    ref.read(appointmentRemoteDatasourceProvider),
  );
});

// Provider para el datasource de citas
final publicAppointmentRemoteDatasourceProvider = Provider((ref) {
  return AppointmentRemoteDatasource();
});

// Provider para la implementacion del repository de citas
final publicAppointmentRepositoryProvider = Provider<AppointmentRepository>((
  ref,
) {
  return AppointmentRepositoryImpl(
    ref.read(publicAppointmentRemoteDatasourceProvider),
  );
});
