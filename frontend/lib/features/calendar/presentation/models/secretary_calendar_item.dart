import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

enum SecretaryCalendarItemType { schedule, blockade, appointment }

class SecretaryCalendarItem {
  final SecretaryCalendarItemType type;
  final DateTime date;
  final Appointment? appointment;
  final Schedule? schedule;

  const SecretaryCalendarItem._({
    required this.type,
    required this.date,
    this.appointment,
    this.schedule,
  });

  factory SecretaryCalendarItem.fromAppointment(Appointment appointment) {
    return SecretaryCalendarItem._(
      type: appointment.isBlockade
          ? SecretaryCalendarItemType.blockade
          : SecretaryCalendarItemType.appointment,
      date: appointment.date,
      appointment: appointment,
    );
  }

  factory SecretaryCalendarItem.fromSchedule(Schedule schedule, DateTime date) {
    return SecretaryCalendarItem._(
      type: SecretaryCalendarItemType.schedule,
      date: date,
      schedule: schedule,
    );
  }

  int get id => appointment?.id ?? schedule!.id;
  int get doctorId => appointment?.doctorId ?? schedule!.doctorId;
  String get doctorName => appointment?.doctorName ?? schedule!.doctorName;
  String get clinicName => appointment?.clinicName ?? schedule!.clinicName;
  String get startTime => appointment?.startTime ?? schedule!.startTime;

  int get durationMinutes {
    if (appointment != null) return appointment!.appointmentDuration;
    return _minutes(schedule!.endTime) - _minutes(schedule!.startTime);
  }

  String get endTime => _formatMinutes(_minutes(startTime) + durationMinutes);
  int get startMinute => _minutes(startTime);
  int get endMinute => startMinute + durationMinutes;

  String get shortLabel => switch (type) {
    SecretaryCalendarItemType.appointment => 'Cita',
    SecretaryCalendarItemType.blockade => 'Bloqueo',
    SecretaryCalendarItemType.schedule => 'Horario',
  };

  String get fullLabel {
    final person = type == SecretaryCalendarItemType.appointment
        ? appointment!.patientName
        : doctorName;
    return '$shortLabel - $person / $clinicName';
  }

  String get timeRange => '${_trimTime(startTime)}–${_trimTime(endTime)}';

  bool containsMinute(double minute) =>
      minute >= startMinute && minute < endMinute;

  static int _minutes(String value) {
    final parts = value.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  static String _formatMinutes(int minutes) {
    final normalized = minutes % (24 * 60);
    return '${(normalized ~/ 60).toString().padLeft(2, '0')}:'
        '${(normalized % 60).toString().padLeft(2, '0')}';
  }

  static String _trimTime(String value) => value.substring(0, 5);
}
