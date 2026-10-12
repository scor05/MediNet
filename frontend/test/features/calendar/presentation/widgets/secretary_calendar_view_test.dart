import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/models/secretary_calendar_item.dart';
import 'package:frontend/features/calendar/presentation/widgets/appointment_card.dart';
import 'package:frontend/features/calendar/presentation/widgets/secretary_calendar_view.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/theme/calendar_theme.dart';

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

  testWidgets('shows type, person, clinic and time range in that order', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final longAppointment = appointment.copyWith(appointmentDuration: 60);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecretaryCalendarView(
            weekStart: DateTime(2026, 9, 21),
            appointments: [longAppointment],
            schedules: const [],
            onItemsTap: (_) {},
          ),
        ),
      ),
    );

    final type = tester.getTopLeft(find.text('Cita')).dy;
    final person = tester.getTopLeft(find.text('Ana Pérez')).dy;
    final clinic = tester.getTopLeft(find.text('Clínica Central')).dy;
    final time = tester.getTopLeft(find.text('08:00–09:00')).dy;

    expect(type, lessThan(person));
    expect(person, lessThan(clinic));
    expect(clinic, lessThan(time));
  });

  testWidgets('schedules show the doctor instead of the patient', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecretaryCalendarView(
            weekStart: DateTime(2026, 9, 21),
            appointments: const [],
            schedules: const [schedule],
            onItemsTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Horario'), findsOneWidget);
    expect(find.text('Dr. Ruiz'), findsOneWidget);
    expect(find.text('Clínica Central'), findsOneWidget);
    expect(find.text('08:00–10:00'), findsOneWidget);
  });

  testWidgets('schedule text sits at the bottom so appointments do not hide it', (
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
            onItemsTap: (_) {},
          ),
        ),
      ),
    );

    final block = tester.getRect(
      find.byKey(const ValueKey('secretary-calendar-schedule-4')),
    );
    final appointmentRect = tester.getRect(
      find.byKey(const ValueKey('secretary-calendar-appointment-1')),
    );
    final label = tester.getRect(find.text('Horario'));

    expect(label.top, greaterThanOrEqualTo(appointmentRect.bottom));
    expect(label.bottom, lessThanOrEqualTo(block.bottom));
  });

  testWidgets('short items drop lower lines instead of shrinking the font', (
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
            schedules: const [],
            onItemsTap: (_) {},
          ),
        ),
      ),
    );

    // 30 minutos: caben tipo y paciente; clínica y horas se omiten.
    expect(find.text('Cita'), findsOneWidget);
    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(find.text('Clínica Central'), findsNothing);
    expect(
      tester.widget<Text>(find.text('Ana Pérez')).style?.fontSize,
      CalendarSizes.itemFontSize,
    );
  });

  testWidgets('long names are ellipsized without reducing the font', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final longName = appointment.copyWith(
      patientName: 'Maria de los Angeles Fernandez de la Cruz y Villatoro',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecretaryCalendarView(
            weekStart: DateTime(2026, 9, 21),
            appointments: [longName],
            schedules: const [],
            onItemsTap: (_) {},
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.textContaining('Maria de los'));
    expect(text.overflow, TextOverflow.ellipsis);
    expect(text.maxLines, 1);
    expect(text.style?.fontSize, CalendarSizes.itemFontSize);
  });

  testWidgets('highlights only the appointment matching the requested id', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final otherAppointment = appointment.copyWith(
      id: 2,
      patientName: 'Luis Gómez',
      startTime: '09:00:00',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecretaryCalendarView(
            weekStart: DateTime(2026, 9, 21),
            appointments: [appointment, otherAppointment],
            schedules: const [],
            highlightedAppointmentId: appointment.id,
            onItemsTap: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 275));

    final selected = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const ValueKey('appointment-highlight-1')),
        matching: find.byType(DecoratedBox),
      ),
    );
    final other = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const ValueKey('appointment-highlight-2')),
        matching: find.byType(DecoratedBox),
      ),
    );

    final selectedDecoration = selected.decoration as BoxDecoration;
    final otherDecoration = other.decoration as BoxDecoration;
    expect(selectedDecoration.border, isNull);
    expect(selectedDecoration.boxShadow, isNotEmpty);
    expect(
      HSLColor.fromColor(selectedDecoration.boxShadow!.single.color).hue,
      closeTo(
        HSLColor.fromColor(appointmentStatusColor(appointment.status)).hue,
        1,
      ),
    );
    expect(otherDecoration.boxShadow, isEmpty);
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

  testWidgets('adds gutters only at the outer edges of each day block', (
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
            onItemsTap: (_) {},
          ),
        ),
      ),
    );

    final day = tester.getRect(
      find.byKey(const ValueKey('secretary-day-column-0')),
    );
    final first = tester.getRect(
      find.byKey(const ValueKey('secretary-calendar-appointment-1')),
    );
    final second = tester.getRect(
      find.byKey(const ValueKey('secretary-calendar-appointment-2')),
    );
    final leftItem = first.left < second.left ? first : second;
    final rightItem = first.left < second.left ? second : first;

    expect(leftItem.left - day.left, CalendarSizes.calendarItemDayEdgeInset);
    expect(day.right - rightItem.right, CalendarSizes.calendarItemDayEdgeInset);
    expect(rightItem.left - leftItem.right, 2);
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
            onItemsTap: (_) {},
          ),
        ),
      ),
    );

    final labels = tester.widgetList<Text>(find.text('Horario'));
    final times = tester.widgetList<Text>(find.text('08:00–10:00'));

    expect(labels, hasLength(3));
    expect(labels.every((text) => text.style?.fontSize == CalendarSizes.itemFontSize), isTrue);
    expect(times, hasLength(3));
    expect(
      times.every((text) => text.style?.fontSize == CalendarSizes.itemFontSize),
      isTrue,
    );
  });
}
