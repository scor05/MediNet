import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/data/providers/appointment_data_providers.dart';
import 'package:frontend/features/appointment/domain/usecases/create_appointment_usecase.dart';
import 'package:frontend/features/appointment/domain/usecases/get_doctor_appointments_usecase.dart';
import 'package:frontend/features/appointment/domain/usecases/get_secretary_appointments_usecase.dart';

// Provider para el usecase getDoctorAppointments
final getDoctorAppointmentsUsecaseProvider = Provider((ref) {
  return GetDoctorAppointmentsUsecase(ref.read(appointmentRepositoryProvider));
});

// Provider para el usecase getSecretaryAppointments
final getSecretaryAppointmentsUsecaseProvider = Provider((ref) {
  return GetSecretaryAppointmentsUsecase(
    ref.read(appointmentRepositoryProvider),
  );
});

// Provider para el usecase createAppointment
final createAppointmentUsecaseProvider = Provider((ref) {
  return CreateAppointmentUsecase(ref.read(appointmentRepositoryProvider));
});
