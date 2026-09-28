import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/calendar/presentation/dialogs/create_appointment_dialog.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/schedule/domain/providers/schedule_domain_providers.dart';
import 'package:frontend/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:frontend/features/schedule/domain/usecases/get_schedules_by_doctor_id_usecase.dart';
import 'package:frontend/features/search/presentation/widgets/search_input_field.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';

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
}

Widget _app(_ScheduleRepository repository, {DoctorSearchResult? fixedDoctor}) {
  return ProviderScope(
    overrides: [
      getSchedulesByDoctorIdUsecaseProvider.overrideWithValue(
        GetSchedulesByDoctorIdUsecase(repository),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: CreateAppointmentDialog(
          weekStart: DateTime(2026, 9, 21),
          fixedDoctor: fixedDoctor,
        ),
      ),
    ),
  );
}

class _ScheduleRepository implements ScheduleRepository {
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
