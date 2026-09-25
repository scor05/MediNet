import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/models/secretary_calendar_item.dart';
import 'package:frontend/features/calendar/presentation/widgets/secretary_calendar_view.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

void main() {
  final appointment = Appointment(
    id: 1,
    scheduleId: 4,
    patientName: 'Ana Pérez',
    date: DateTime(2026, 9, 21),
    startTime: '08:00:00',
    status: 'accepted',
    createdAt: DateTime(2026, 9, 1),
    createdBy: 1,
    updatedAt: DateTime(2026, 9, 1),
    updatedBy: 1,
    doctorId: 7,
    doctorName: 'Dr. Ruiz',
    clinicId: 2,
    clinicName: 'Clínica Central',
    appointmentDuration: 30,
  );
  const schedule = Schedule(
    id: 4,
    dayOfWeek: 0,
    startTime: '08:00:00',
    endTime: '10:00:00',
    duration: 30,
    doctorId: 7,
    doctorName: 'Dr. Ruiz',
    clinicId: 2,
    clinicName: 'Clínica Central',
  );

  testWidgets('uses compact labels and returns underlying layers on tap', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(700, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    List<SecretaryCalendarItem>? tapped;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecretaryCalendarView(
            weekStart: DateTime(2026, 9, 21),
            appointments: [appointment],
            schedules: const [schedule],
            doctorColors: const {7: Color.fromARGB(255, 110, 150, 180)},
            onItemsTap: (items) => tapped = items,
          ),
        ),
      ),
    );

    expect(find.text('Cita'), findsOneWidget);
    expect(find.text('Horario'), findsOneWidget);

    await tester.tap(find.text('Cita'));

    expect(tapped, isNotNull);
    expect(tapped!.map((item) => item.type), [
      SecretaryCalendarItemType.appointment,
      SecretaryCalendarItemType.schedule,
    ]);
  });

  testWidgets('uses the complete item format when a column is wide enough', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecretaryCalendarView(
            weekStart: DateTime(2026, 9, 21),
            appointments: [appointment],
            schedules: const [schedule],
            doctorColors: const {7: Color.fromARGB(255, 110, 150, 180)},
            onItemsTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Cita - Ana Pérez / Clínica Central'), findsOneWidget);
    expect(find.text('Horario - Dr. Ruiz / Clínica Central'), findsOneWidget);
  });

  testWidgets('places simultaneous appointments in separate columns', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final simultaneous = appointment.copyWith(
      id: 2,
      patientName: 'Luis Gómez',
      doctorId: 8,
      doctorName: 'Dra. López',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecretaryCalendarView(
            weekStart: DateTime(2026, 9, 21),
            appointments: [appointment, simultaneous],
            schedules: const [],
            doctorColors: const {
              7: Color.fromARGB(255, 110, 150, 180),
              8: Color.fromARGB(255, 170, 130, 160),
            },
            onItemsTap: (_) {},
          ),
        ),
      ),
    );

    final first = tester.getRect(find.textContaining('Ana Pérez'));
    final second = tester.getRect(find.textContaining('Luis Gómez'));

    expect(first.left, isNot(second.left));
    expect(first.width, lessThan(120));
    expect(second.width, lessThan(120));
  });

  testWidgets('keeps readable text sizes when three schedules collide', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1920, 1080));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final schedules = List.generate(
      3,
      (index) => schedule.copyWith(
        id: index + 1,
        doctorId: index + 1,
        doctorName: 'Doctor ${index + 1}',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecretaryCalendarView(
            weekStart: DateTime(2026, 9, 21),
            appointments: const [],
            schedules: schedules,
            doctorColors: const {
              1: Colors.blue,
              2: Colors.green,
              3: Colors.purple,
            },
            onItemsTap: (_) {},
          ),
        ),
      ),
    );

    final labels = tester.widgetList<Text>(find.text('Horario'));
    final times = tester.widgetList<Text>(find.text('08:00–10:00'));

    expect(labels, hasLength(3));
    expect(labels.every((text) => text.style?.fontSize == 10), isTrue);
    expect(times, hasLength(3));
    expect(times.every((text) => text.style?.fontSize == 10), isTrue);
  });
}
