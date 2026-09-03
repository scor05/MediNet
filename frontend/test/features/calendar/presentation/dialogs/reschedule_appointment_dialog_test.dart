import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';
import 'package:frontend/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:frontend/features/appointment/domain/usecases/reschedule_appointment_usecase.dart';
import 'package:frontend/features/calendar/presentation/dialogs/appointment_detail_dialog.dart';
import 'package:frontend/features/calendar/presentation/dialogs/reschedule_appointment_dialog.dart';

void main() {
  testWidgets('places Reprogramar between cancellation and close actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: AppointmentDetailDialog(
              appointment: _appt,
              canReschedule: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.autorenew), findsOneWidget);
    final cancelY = tester.getCenter(find.text('Cancelar cita')).dy;
    final rescheduleY = tester.getCenter(find.text('Reprogramar')).dy;
    final closeY = tester.getCenter(find.text('Cerrar')).dy;

    expect(cancelY, lessThan(rescheduleY));
    expect(rescheduleY, lessThan(closeY));
  });

  testWidgets('hides Reprogramar unless the calendar explicitly allows it', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: AppointmentDetailDialog(appointment: _appt)),
        ),
      ),
    );

    expect(find.text('Reprogramar'), findsNothing);
    expect(find.byIcon(Icons.autorenew), findsNothing);
  });

  testWidgets('shows availability error and keeps confirmation disabled', (
    tester,
  ) async {
    final repository = _RescheduleRepository(
      validationError: 'El horario seleccionado ya está ocupado.',
    );
    await _pumpDialog(tester, repository);
    await tester.pumpAndSettle();

    final calendar = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    expect(calendar.firstDate, DateTime(2026, 9, 3));
    expect(
      find.text('El horario seleccionado ya está ocupado.'),
      findsOneWidget,
    );

    final confirm = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirmar reprogramación'),
    );
    expect(confirm.onPressed, isNull);
  });

  testWidgets('submits a server-approved reschedule', (tester) async {
    final repository = _RescheduleRepository();
    await _pumpDialog(tester, repository);
    await tester.pumpAndSettle();

    final confirmFinder = find.widgetWithText(
      FilledButton,
      'Confirmar reprogramación',
    );
    expect(tester.widget<FilledButton>(confirmFinder).onPressed, isNotNull);

    await tester.tap(confirmFinder);
    await tester.pumpAndSettle();

    expect(repository.rescheduleCalls, 1);
    expect(find.byType(RescheduleAppointmentDialog), findsNothing);
  });

  testWidgets('refreshes the calendar and shows success after rescheduling', (
    tester,
  ) async {
    final repository = _RescheduleRepository();
    var refreshCalls = 0;
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          rescheduleAppointmentUsecaseProvider.overrideWithValue(
            RescheduleAppointmentUsecase(repository),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () => showAppointmentDetailSheet(
                  context: context,
                  appointment: _appt,
                  canReschedule: true,
                  onRescheduled: () async {
                    refreshCalls++;
                  },
                ),
                child: const Text('Abrir detalle'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir detalle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reprogramar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar reprogramación'));
    await tester.pumpAndSettle();

    expect(refreshCalls, 1);
    expect(
      find.text('La cita fue reprogramada correctamente.'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpDialog(
  WidgetTester tester,
  _RescheduleRepository repository,
) async {
  await tester.binding.setSurfaceSize(const Size(900, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        rescheduleAppointmentUsecaseProvider.overrideWithValue(
          RescheduleAppointmentUsecase(repository),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: RescheduleAppointmentDialog(
            appointment: _appt,
            openedAt: DateTime(2026, 9, 3, 8),
          ),
        ),
      ),
    ),
  );
}

final _appt = Appointment(
  id: 20,
  scheduleId: 4,
  patientId: 7,
  patientName: 'Paciente',
  date: DateTime(2026, 9, 4),
  startTime: '10:00:00',
  status: 'accepted',
  createdAt: DateTime(2026, 8, 1),
  createdBy: 3,
  updatedAt: DateTime(2026, 8, 1),
  updatedBy: 3,
  doctorId: 3,
  doctorName: 'Doctor',
  clinicId: 2,
  clinicName: 'Clínica',
  appointmentDuration: 30,
);

class _RescheduleRepository implements AppointmentRepository {
  final String? validationError;
  int rescheduleCalls = 0;

  _RescheduleRepository({this.validationError});

  @override
  Future<void> checkRescheduleAvailability({
    required int appointmentId,
    required DateTime date,
    required TimeOfDay startTime,
  }) async {
    if (validationError != null) throw ApiException(validationError!);
  }

  @override
  Future<void> rescheduleAppointment({
    required int appointmentId,
    required DateTime date,
    required TimeOfDay startTime,
  }) async {
    rescheduleCalls++;
  }

  @override
  Future<Appointment> createAppointment({
    required int scheduleId,
    required DateTime date,
    required TimeOfDay startTime,
    required String patientName,
    int? patientId,
    required String status,
  }) => throw UnimplementedError();

  @override
  Future<List<Appointment>> getDoctorAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? clientId,
    int? clinicId,
  }) => throw UnimplementedError();

  @override
  Future<List<Appointment>> getPatientAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) => throw UnimplementedError();

  @override
  Future<List<Appointment>> getPublicAppointments({
    int? doctorId,
    int? clinicId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) => throw UnimplementedError();

  @override
  Future<List<Appointment>> getSecretaryAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? doctorId,
    int? clinicId,
    String? status,
  }) => throw UnimplementedError();

  @override
  Future<void> updateAppointmentStatus({
    required int appointmentId,
    required String status,
  }) => throw UnimplementedError();
}
