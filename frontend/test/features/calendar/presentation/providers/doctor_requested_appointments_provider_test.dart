import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';
import 'package:frontend/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:frontend/features/appointment/domain/usecases/get_doctor_appointments_usecase.dart';
import 'package:frontend/features/appointment/domain/usecases/decide_appointment_usecase.dart';
import 'package:frontend/features/calendar/presentation/providers/doctor_requested_appointments_provider.dart';

void main() {
  test(
    'keeps only requested appointments returned for the logged-in doctor',
    () async {
      final repository = _AppointmentRepository([
        _appointment(id: 1, status: 'requested'),
        _appointment(id: 2, status: 'accepted'),
        _appointment(id: 3, status: 'requested', type: 'blockade'),
      ]);
      final container = ProviderContainer(
        overrides: [
          getDoctorAppointmentsUsecaseProvider.overrideWithValue(
            GetDoctorAppointmentsUsecase(repository),
          ),
          decideAppointmentUsecaseProvider.overrideWithValue(
            DecideAppointmentUsecase(repository),
          ),
        ],
      );
      addTearDown(container.dispose);

      final appointments = await container.read(
        doctorRequestedAppointmentsNotifierProvider.future,
      );

      expect(appointments.map((appointment) => appointment.id), [1]);

      await container
          .read(doctorRequestedAppointmentsNotifierProvider.notifier)
          .updateStatus(appointmentId: 1, status: 'accepted');

      expect(repository.updatedAppointmentId, 1);
      expect(repository.updatedStatus, 'accepted');
      expect(
        container.read(doctorRequestedAppointmentsNotifierProvider).value,
        isEmpty,
      );
    },
  );
}

Appointment _appointment({
  required int id,
  required String status,
  String type = 'appointment',
}) {
  return Appointment(
    id: id,
    scheduleId: 10,
    patientId: 20,
    patientName: 'Paciente',
    date: DateTime(2026, 9, 28),
    startTime: '08:00:00',
    status: status,
    createdAt: DateTime(2026, 9, 1),
    createdBy: 20,
    updatedAt: DateTime(2026, 9, 1),
    updatedBy: 20,
    doctorId: 3,
    doctorName: 'Doctor',
    clinicId: 4,
    clinicName: 'Clínica',
    appointmentDuration: 30,
    type: type,
  );
}

class _AppointmentRepository extends Fake implements AppointmentRepository {
  final List<Appointment> appointments;
  int? updatedAppointmentId;
  String? updatedStatus;

  _AppointmentRepository(this.appointments);

  @override
  Future<List<Appointment>> getDoctorAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? clientId,
    int? clinicId,
  }) async => appointments;

  @override
  Future<void> updateAppointmentStatus({
    required int appointmentId,
    required String status,
  }) async {
    updatedAppointmentId = appointmentId;
    updatedStatus = status;
  }

  @override
  Future<void> decideAppointment({
    required int appointmentId,
    required String decision,
  }) async {
    updatedAppointmentId = appointmentId;
    updatedStatus = decision == 'accept' ? 'accepted' : 'rejected';
  }
}
