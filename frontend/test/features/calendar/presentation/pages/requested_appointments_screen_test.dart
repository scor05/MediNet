import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';
import 'package:frontend/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:frontend/features/appointment/domain/usecases/get_secretary_requested_appointments_usecase.dart';
import 'package:frontend/features/calendar/presentation/pages/secretary_requested_appointments_screen.dart';

void main() {
  testWidgets('shows the original slot on a backup request card', (
    tester,
  ) async {
    final repository = _RequestedAppointmentsRepository([
      Appointment(
        id: 8,
        scheduleId: 3,
        patientId: 5,
        patientName: 'Paciente',
        date: DateTime(2026, 10, 5),
        startTime: '14:00:00',
        status: 'backup_pending',
        createdAt: DateTime(2026, 9, 27),
        createdBy: 5,
        updatedAt: DateTime(2026, 9, 27),
        updatedBy: 5,
        doctorId: 2,
        doctorName: 'Doctor',
        clinicId: 1,
        clinicName: 'Clínica',
        appointmentDuration: 30,
        backupTargetDate: DateTime(2026, 10, 4),
        backupTargetStartTime: '09:30:00',
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getSecretaryRequestedAppointmentsUsecaseProvider.overrideWithValue(
            GetSecretaryRequestedAppointmentsUsecase(repository),
          ),
        ],
        child: const MaterialApp(home: SecretaryRequestedAppointmentsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cita original'), findsOneWidget);
    expect(find.text('Fecha: 04/10/2026'), findsOneWidget);
    expect(find.text('Hora: 09:30'), findsOneWidget);
  });
}

class _RequestedAppointmentsRepository extends Fake
    implements AppointmentRepository {
  final List<Appointment> appointments;

  _RequestedAppointmentsRepository(this.appointments);

  @override
  Future<List<Appointment>> getSecretaryAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? doctorId,
    int? clinicId,
    String? status,
  }) async => appointments;
}
