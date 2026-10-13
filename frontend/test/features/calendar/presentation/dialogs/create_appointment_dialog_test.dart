import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/calendar/presentation/dialogs/create_appointment_dialog.dart';
import 'package:frontend/features/calendar/presentation/providers/create_appointment_form_provider.dart';
import 'package:frontend/features/clinic/domain/entities/clinic_search_result.dart';
import 'package:frontend/features/calendar/presentation/widgets/keyboard_aware_bottom_sheet.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/providers/schedule_domain_providers.dart';
import 'package:frontend/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:frontend/features/schedule/domain/usecases/get_schedules_by_doctor_id_usecase.dart';
import 'package:frontend/features/search/presentation/widgets/search_input_field.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';
import 'package:frontend/features/user/domain/entities/user.dart';

void main() {
  testWidgets('doctor flow fixes the logged-in doctor and shows clinic next', (
    tester,
  ) async {
    final repository = _ScheduleRepository();

    await tester.pumpWidget(
      _app(
        repository,
        fixedDoctor: const DoctorSearchResult(
          id: 36,
          name: 'Doom Slayer',
          specialty: 'Medicina general',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final doctorField = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Doctor'),
    );
    expect(doctorField.enabled, isFalse);
    expect(find.text('Doom Slayer'), findsOneWidget);
    expect(find.byType(KeyboardAwareBottomSheet), findsOneWidget);
    expect(find.byType(SearchInputField<DoctorSearchResult>), findsNothing);
    expect(find.widgetWithText(TextField, 'Clínica'), findsOneWidget);
    expect(repository.requestedDoctorId, 36);
  });

  testWidgets('secretary flow retains the editable doctor search', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_ScheduleRepository()));
    await tester.pump();

    expect(find.byType(SearchInputField<DoctorSearchResult>), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Doctor'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Clínica'), findsNothing);
  });

  testWidgets('keeps the appointment action visible above the keyboard', (
    tester,
  ) async {
    const screenSize = Size(360, 640);
    const keyboardHeight = 300.0;
    await tester.binding.setSurfaceSize(screenSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _app(
        _ScheduleRepository(),
        fixedDoctor: const DoctorSearchResult(
          id: 36,
          name: 'Doom Slayer',
          specialty: 'Medicina general',
        ),
        mediaQueryData: const MediaQueryData(
          size: screenSize,
          viewInsets: EdgeInsets.only(bottom: keyboardHeight),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final action = find.byKey(const ValueKey('appointment-submit-area'));
    expect(action, findsOneWidget);
    expect(
      tester.getBottomRight(action).dy,
      lessThanOrEqualTo(screenSize.height - keyboardHeight),
    );
    expect(tester.takeException(), isNull);
  });

  group('patient search', () {
    const doctor = DoctorSearchResult(
      id: 36,
      name: 'Doom Slayer',
      specialty: 'Medicina general',
    );

    Future<ProviderContainer> openPatientField(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(_ScheduleRepository(), fixedDoctor: doctor));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CreateAppointmentDialog)),
      );
      container
          .read(createAppointmentFormProvider(DateTime(2026, 9, 21)).notifier)
          .selectClinic(
            const ClinicSearchResult(
              id: 1,
              name: 'Clínica Central',
              address: 'Zona 1',
            ),
          );
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('asks to pick a patient from the list', (tester) async {
      await openPatientField(tester);

      expect(find.text('Selecciona un paciente de la lista'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('appointment-patient-selected')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('appointment-patient-clear')),
        findsNothing,
      );
    });

    testWidgets('typed text is flagged as not selected and can be erased', (
      tester,
    ) async {
      await openPatientField(tester);

      await tester.enterText(find.widgetWithText(TextField, 'Paciente'), 'A');
      await tester.pump();

      expect(
        find.byKey(const ValueKey('appointment-patient-typed-hint')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('appointment-patient-selected')),
        findsNothing,
      );

      await tester.tap(find.byKey(const ValueKey('appointment-patient-clear')));
      await tester.pump();

      expect(
        tester
            .widget<TextField>(find.widgetWithText(TextField, 'Paciente'))
            .controller
            ?.text,
        isEmpty,
      );
      expect(
        find.byKey(const ValueKey('appointment-patient-typed-hint')),
        findsNothing,
      );
    });

    testWidgets('shows the selected patient and lets the user change it', (
      tester,
    ) async {
      final container = await openPatientField(tester);

      container
          .read(createAppointmentFormProvider(DateTime(2026, 9, 21)).notifier)
          .selectPatient(
            User(
              id: 3,
              name: 'Diego Gudiel',
              email: 'diego@example.com',
              phone: '50233333333',
              isAccountActive: true,
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026),
            ),
          );
      await tester.pump();

      expect(
        find.text('Paciente seleccionado: Diego Gudiel (diego@example.com)'),
        findsOneWidget,
      );
      expect(find.text('Selecciona un paciente de la lista'), findsNothing);
      expect(find.text('Cambiar'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('appointment-patient-clear')));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('appointment-patient-selected')),
        findsNothing,
      );
      expect(find.text('Selecciona un paciente de la lista'), findsOneWidget);
    });
  });
}

Widget _app(
  _ScheduleRepository repository, {
  DoctorSearchResult? fixedDoctor,
  MediaQueryData? mediaQueryData,
}) {
  final page = Scaffold(
    resizeToAvoidBottomInset: false,
    body: CreateAppointmentDialog(
      weekStart: DateTime(2026, 9, 21),
      fixedDoctor: fixedDoctor,
    ),
  );

  return ProviderScope(
    overrides: [
      getSchedulesByDoctorIdUsecaseProvider.overrideWithValue(
        GetSchedulesByDoctorIdUsecase(repository),
      ),
    ],
    child: MaterialApp(
      home: mediaQueryData == null
          ? page
          : MediaQuery(data: mediaQueryData, child: page),
    ),
  );
}

class _ScheduleRepository extends ScheduleRepository {
  int? requestedDoctorId;

  @override
  Future<List<Schedule>> getSchedulesByDoctorId(int doctorId) async {
    requestedDoctorId = doctorId;
    return const [
      Schedule(
        id: 1,
        dayOfWeek: 0,
        startTime: '08:00:00',
        endTime: '12:00:00',
        duration: 30,
        doctorId: 36,
        doctorName: 'Doom Slayer',
        clinicId: 1,
        clinicName: 'Clínica Central',
      ),
    ];
  }

  @override
  Future<Schedule> createSchedule({
    int? doctorId,
    required int clinicId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteSchedule(int id) => throw UnimplementedError();

  @override
  Future<List<Schedule>> getDoctorSchedules() async => const [];

  @override
  Future<List<Schedule>> getSecretarySchedules() async => const [];

  @override
  Future<Schedule> updateSchedule({
    required int id,
    required int clinicId,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) => throw UnimplementedError();
}
