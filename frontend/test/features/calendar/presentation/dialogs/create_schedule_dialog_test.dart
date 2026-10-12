import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/calendar/presentation/dialogs/create_schedule_dialog.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/features/clinic/domain/providers/clinic_domain_providers.dart';
import 'package:frontend/features/clinic/domain/repositories/clinic_repository.dart';
import 'package:frontend/features/clinic/domain/usecases/get_clinics_usecase.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/providers/schedule_domain_providers.dart';
import 'package:frontend/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:frontend/features/schedule/domain/usecases/create_schedule_usecase.dart';
import 'package:frontend/features/schedule/domain/usecases/get_doctor_schedules_usecase.dart';
import 'package:frontend/features/schedule/domain/usecases/get_schedules_by_doctor_id_usecase.dart';
import 'package:frontend/features/search/presentation/providers/search_form_provider.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';
import 'package:frontend/theme/app_theme.dart';

void main() {
  testWidgets('shows the doctor search only for secretary schedule creation', (
    tester,
  ) async {
    await tester.pumpWidget(_app(forSecretary: true));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Doctor'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNull);
    expect(find.byKey(const ValueKey('schedule-day-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('schedule-day-6')), findsOneWidget);
    expect(find.text('Día de la semana'), findsNothing);
    expect(tester.widget<Text>(find.text('08:00')).style?.fontSize, 16);
    expect(tester.widget<Text>(find.text('16:00')).style?.fontSize, 16);
    final unselectedButton = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('schedule-day-0')),
    );
    expect(unselectedButton.style?.side?.resolve({}), BorderSide.none);

    await tester.pumpWidget(_app(forSecretary: false));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Doctor'), findsNothing);
    expect(_submitButton(tester).onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey('schedule-day-0')));
    await tester.pump();
    expect(_submitButton(tester).onPressed, isNotNull);

    await tester.tap(find.byKey(const ValueKey('schedule-day-2')));
    await tester.pump();
    expect(_submitButton(tester).onPressed, isNotNull);

    await tester.tap(find.byKey(const ValueKey('schedule-day-0')));
    await tester.tap(find.byKey(const ValueKey('schedule-day-2')));
    await tester.pump();
    expect(_submitButton(tester).onPressed, isNull);
  });

  testWidgets('explains that a doctor must be picked from the list', (
    tester,
  ) async {
    await tester.pumpWidget(_app(forSecretary: true));
    await tester.pumpAndSettle();

    expect(find.text('Selecciona un doctor de la lista'), findsOneWidget);
    expect(find.byKey(const ValueKey('schedule-doctor-selected')), findsNothing);
    expect(find.byKey(const ValueKey('schedule-submit-hint')), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNull);

    // Un doctor solo cuenta cuando se elige de las sugerencias.
    await tester.tap(find.byKey(const ValueKey('schedule-day-0')));
    await tester.pump();
    expect(_submitButton(tester).onPressed, isNull);
  });

  testWidgets('typed text is not treated as a selected doctor', (
    tester,
  ) async {
    await tester.pumpWidget(_app(forSecretary: true));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Doctor'), 'Fig');
    await tester.pump();

    expect(find.text('Selecciona un doctor de la lista'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('schedule-doctor-typed-hint')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('schedule-doctor-selected')), findsNothing);
    expect(_submitButton(tester).onPressed, isNull);
  });

  testWidgets('shows the selected doctor and enables saving', (tester) async {
    await tester.pumpWidget(_app(forSecretary: true));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(CreateScheduleDialog)),
    );
    container
        .read(searchFormNotifierProvider.notifier)
        .selectDoctor(
          const DoctorSearchResult(
            id: 7,
            name: 'Dr Figueroa',
            specialty: 'Pediatría',
          ),
        );
    await tester.tap(find.byKey(const ValueKey('schedule-day-0')));
    await tester.pump();

    expect(find.text('Doctor seleccionado: Dr Figueroa'), findsOneWidget);
    expect(find.text('Selecciona un doctor de la lista'), findsNothing);
    expect(find.byKey(const ValueKey('schedule-submit-hint')), findsNothing);
    expect(_submitButton(tester).onPressed, isNotNull);
  });

  group('existing schedules', () {
    const monday = Schedule(
      id: 1,
      dayOfWeek: 0,
      startTime: '14:00:00',
      endTime: '16:00:00',
      duration: 30,
      doctorId: 7,
      clinicId: 1,
      clinicName: 'Clínica Central',
    );
    const mondayMorning = Schedule(
      id: 2,
      dayOfWeek: 0,
      startTime: '08:00:00',
      endTime: '12:00:00',
      duration: 30,
      doctorId: 7,
      clinicId: 1,
      clinicName: 'Clínica Central',
    );
    const friday = Schedule(
      id: 3,
      dayOfWeek: 4,
      startTime: '09:00:00',
      endTime: '13:00:00',
      duration: 30,
      doctorId: 7,
      clinicId: 1,
      clinicName: 'Clínica Central',
    );
    const otherClinic = Schedule(
      id: 4,
      dayOfWeek: 2,
      startTime: '07:00:00',
      endTime: '09:00:00',
      duration: 30,
      doctorId: 7,
      clinicId: 99,
      clinicName: 'Otra clínica',
    );

    testWidgets('doctor sees their schedules grouped by day', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _RecordingScheduleRepository(
        existing: const [monday, friday, mondayMorning, otherClinic],
      );
      await tester.pumpWidget(
        _app(forSecretary: false, scheduleRepository: repository),
      );
      await tester.pumpAndSettle();

      expect(find.text('Horarios existentes'), findsOneWidget);
      expect(find.text('08:00–12:00 · 14:00–16:00'), findsOneWidget);
      expect(find.text('09:00–13:00'), findsOneWidget);
      // Solo se muestra la clínica seleccionada.
      expect(find.text('07:00–09:00'), findsNothing);
      expect(
        find.byKey(const ValueKey('existing-schedules-day-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('existing-schedules-day-2')),
        findsNothing,
      );
      expect(
        find.text('Sin horario: Martes, Miércoles, Jueves, Sábado, Domingo'),
        findsOneWidget,
      );
    });

    testWidgets('doctor with no schedules sees every day available', (
      tester,
    ) async {
      await tester.pumpWidget(_app(forSecretary: false));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('existing-schedules-empty')),
        findsOneWidget,
      );
    });

    testWidgets('secretary sees the panel only after choosing a doctor', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _RecordingScheduleRepository(
        existing: const [monday, friday],
      );
      await tester.pumpWidget(
        _app(forSecretary: true, scheduleRepository: repository),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('existing-schedules-panel')),
        findsNothing,
      );
      expect(repository.requestedDoctorId, isNull);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CreateScheduleDialog)),
      );
      container
          .read(searchFormNotifierProvider.notifier)
          .selectDoctor(
            const DoctorSearchResult(
              id: 7,
              name: 'Dr Figueroa',
              specialty: 'Pediatría',
            ),
          );
      await tester.pumpAndSettle();

      expect(repository.requestedDoctorId, 7);
      expect(find.text('Dr Figueroa · Clínica Central'), findsOneWidget);
      expect(find.text('14:00–16:00'), findsOneWidget);
      expect(find.text('09:00–13:00'), findsOneWidget);
    });
  });

  testWidgets('creates one schedule for every selected day', (tester) async {
    final scheduleRepository = _RecordingScheduleRepository();
    await tester.pumpWidget(
      _app(forSecretary: false, scheduleRepository: scheduleRepository),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('schedule-day-4')));
    await tester.tap(find.byKey(const ValueKey('schedule-day-1')));
    await tester.pump();

    final selectedButton = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('schedule-day-1')),
    );
    expect(
      selectedButton.style?.backgroundColor?.resolve({}),
      AppTheme.primary,
    );
    expect(selectedButton.style?.foregroundColor?.resolve({}), Colors.white);
    expect(selectedButton.style?.side?.resolve({}), BorderSide.none);
    await tester.tap(find.text('Guardar horario'));
    await tester.pumpAndSettle();

    expect(scheduleRepository.createdDays, [1, 4]);
    expect(scheduleRepository.batchCalls, 1);
  });
}

FilledButton _submitButton(WidgetTester tester) => tester.widget<FilledButton>(
  find.widgetWithText(FilledButton, 'Guardar horario'),
);

Widget _app({
  required bool forSecretary,
  ScheduleRepository? scheduleRepository,
}) {
  final repository = _ClinicRepository();
  final schedules = scheduleRepository ?? _RecordingScheduleRepository();
  return ProviderScope(
    overrides: [
      getClinicsUsecaseProvider.overrideWithValue(
        GetClinicsUsecase(repository),
      ),
      createScheduleUsecaseProvider.overrideWithValue(
        CreateScheduleUsecase(schedules),
      ),
      getDoctorSchedulesUsecaseProvider.overrideWithValue(
        GetDoctorSchedulesUsecase(schedules),
      ),
      getSchedulesByDoctorIdUsecaseProvider.overrideWithValue(
        GetSchedulesByDoctorIdUsecase(schedules),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(body: CreateScheduleDialog(forSecretary: forSecretary)),
    ),
  );
}

class _RecordingScheduleRepository extends ScheduleRepository {
  final List<int> createdDays = [];
  final List<Schedule> existing;
  int batchCalls = 0;
  int? requestedDoctorId;

  _RecordingScheduleRepository({this.existing = const []});

  Schedule _schedule({
    required int dayOfWeek,
    required int clinicId,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
    int? doctorId,
  }) {
    return Schedule(
      id: dayOfWeek + 1,
      dayOfWeek: dayOfWeek,
      startTime: '${startTime.hour}:00',
      endTime: '${endTime.hour}:00',
      duration: duration,
      doctorId: doctorId ?? 1,
      clinicId: clinicId,
      clinicName: 'Clínica Central',
    );
  }

  @override
  Future<List<Schedule>> createSchedules({
    int? doctorId,
    required int clinicId,
    required List<int> daysOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) async {
    batchCalls++;
    createdDays.addAll(daysOfWeek);
    return daysOfWeek
        .map(
          (day) => _schedule(
            dayOfWeek: day,
            clinicId: clinicId,
            startTime: startTime,
            endTime: endTime,
            duration: duration,
            doctorId: doctorId,
          ),
        )
        .toList();
  }

  @override
  Future<Schedule> createSchedule({
    int? doctorId,
    required int clinicId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) async {
    createdDays.add(dayOfWeek);
    return _schedule(
      dayOfWeek: dayOfWeek,
      clinicId: clinicId,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      doctorId: doctorId,
    );
  }

  @override
  Future<void> deleteSchedule(int id) async {}

  @override
  Future<List<Schedule>> getDoctorSchedules() async => existing;

  @override
  Future<List<Schedule>> getSchedulesByDoctorId(int doctorId) async {
    requestedDoctorId = doctorId;
    return existing;
  }

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

class _ClinicRepository implements ClinicRepository {
  final clinic = Clinic(
    id: 1,
    name: 'Clínica Central',
    address: 'Zona 1',
    phone: '2222-2222',
    email: 'clinica@example.com',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    isActive: true,
  );

  @override
  Future<List<Clinic>> getClinics(int? clientId) async => [clinic];

  @override
  Future<Clinic> createClinic({
    required String name,
    required String address,
    required String phone,
    required String email,
    required int clientId,
  }) async => clinic;

  @override
  Future<void> deleteClinic(int clinicId) async {}

  @override
  Future<Clinic> updateClinic({
    required int clinicId,
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async => clinic;
}
