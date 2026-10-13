import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/models/secretary_calendar_item.dart';
import 'package:frontend/features/calendar/presentation/utils/block_schedule_utils.dart';
import 'package:frontend/features/calendar/presentation/widgets/appointment_card.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_app_bar.dart';
import 'package:frontend/features/calendar/presentation/widgets/secretary_calendar_view.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/theme/calendar_theme.dart';

void main() {
  final appointment = Appointment(
    id: 11,
    scheduleId: 4,
    patientName: 'Paciente con un nombre suficientemente largo',
    date: DateTime(2026, 9, 21),
    startTime: '08:00:00',
    status: 'accepted',
    createdAt: DateTime(2026, 9, 1),
    createdBy: 1,
    updatedAt: DateTime(2026, 9, 1),
    updatedBy: 1,
    doctorId: 7,
    doctorName: 'Dra. Rivera',
    clinicId: 2,
    clinicName: 'Clinica Central',
    appointmentDuration: 30,
  );
  final blockade = appointment.copyWith(
    id: 12,
    patientName: '',
    type: 'blockade',
    appointmentDuration: 60,
  );
  const schedule = Schedule(
    id: 4,
    dayOfWeek: 0,
    startTime: '08:00:00',
    endTime: '10:00:00',
    duration: 30,
    doctorId: 7,
    doctorName: 'Dra. Rivera',
    clinicId: 2,
    clinicName: 'Clinica Central',
  );
  final otherDoctorSchedule = schedule.copyWith(
    id: 9,
    doctorId: 8,
    doctorName: 'Dr. Ajeno',
  );

  for (final viewport in <(String, Size)>[
    ('desktop', const Size(1440, 900)),
    ('movil', const Size(360, 640)),
  ]) {
    testWidgets(
      'cita, horario y bloqueo superpuestos funcionan en ${viewport.$1}',
      (tester) async {
        await tester.binding.setSurfaceSize(viewport.$2);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final semantics = tester.ensureSemantics();
        List<SecretaryCalendarItem>? selected;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SecretaryCalendarView(
                weekStart: DateTime(2026, 9, 21),
                appointments: [appointment, blockade],
                schedules: [schedule, otherDoctorSchedule],
                onItemsTap: (items) => selected = items,
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(
          find.bySemanticsLabel(RegExp('Cita - Paciente.*08:00.*08:30')),
          findsOneWidget,
        );

        final patientText = tester.widget<Text>(
          find.text('Paciente con un nombre suficientemente largo'),
        );
        expect(patientText.maxLines, 1);
        expect(patientText.overflow, TextOverflow.ellipsis);

        await tester.tap(
          find.byKey(const ValueKey('secretary-calendar-appointment-11')),
        );
        await tester.pump();

        expect(selected, isNotNull);
        expect(selected!.map((item) => item.type), [
          SecretaryCalendarItemType.appointment,
          SecretaryCalendarItemType.blockade,
          SecretaryCalendarItemType.schedule,
        ]);
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );
  }

  testWidgets('la navegacion semanal tiene etiquetas y ejecuta sus acciones', (
    tester,
  ) async {
    var previous = 0;
    var next = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: CalendarAppBar(
            title: '21 - 27 de septiembre',
            onPreviousWeek: () => previous++,
            onNextWeek: () => next++,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Semana anterior'));
    await tester.tap(find.byTooltip('Semana siguiente'));

    expect(previous, 1);
    expect(next, 1);
  });

  testWidgets('la tarjeta de doctor expone el detalle al lector de pantalla', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 150,
            height: 50,
            child: AppointmentCard(appointment: blockade, onTap: () {}),
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(
        'Bloqueo, Dra. Rivera, Clinica Central, 08:00 a 09:00',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  test('los estados equivalentes conservan colores uniformes y legibles', () {
    expect(
      appointmentStatusColor('backup_accepted'),
      appointmentStatusColor('accepted'),
    );
    expect(
      appointmentStatusColor('backup_pending'),
      appointmentStatusColor('requested'),
    );
    expect(
      appointmentStatusColor('backup_cancelled'),
      appointmentStatusColor('cancelled'),
    );

    expect(
      _contrastRatio(Colors.white, CalendarColors.appointmentBlockade),
      greaterThanOrEqualTo(4.5),
    );
    for (final background in [
      CalendarColors.appointmentAccepted,
      CalendarColors.appointmentRequested,
      CalendarColors.appointmentCancelled,
      CalendarColors.appointmentUnknown,
    ]) {
      final foreground = Color.alphaBlend(Colors.black87, background);
      expect(_contrastRatio(foreground, background), greaterThanOrEqualTo(4.5));
    }
  });

  test('deduplica clínicas y resuelve el horario que contiene el bloqueo', () {
    final afternoonSchedule = schedule.copyWith(
      id: 5,
      startTime: '12:00:00',
      endTime: '16:00:00',
    );
    final schedules = [schedule, afternoonSchedule];

    expect(uniqueClinicSchedules(schedules), hasLength(1));
    expect(
      scheduleContainingBlockade(
        schedules: schedules,
        clinicId: 2,
        startTime: const TimeOfDay(hour: 13, minute: 0),
        endTime: const TimeOfDay(hour: 14, minute: 0),
      )?.id,
      5,
    );
    expect(
      scheduleContainingBlockade(
        schedules: schedules,
        clinicId: 2,
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      ),
      isNull,
    );
  });
}

double _contrastRatio(Color first, Color second) {
  final lighter = first.computeLuminance() > second.computeLuminance()
      ? first.computeLuminance()
      : second.computeLuminance();
  final darker = first.computeLuminance() > second.computeLuminance()
      ? second.computeLuminance()
      : first.computeLuminance();
  return (lighter + 0.05) / (darker + 0.05);
}
