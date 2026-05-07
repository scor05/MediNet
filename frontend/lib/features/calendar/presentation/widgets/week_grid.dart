import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/widgets/day_column.dart';

class WeekGrid extends StatelessWidget {
  final List<DateTime> days;
  final List<Appointment> appointments;
  final bool showDoctor;
  final bool showPatient;
  final int startHour;
  final int endHour;
  final double hourHeight;

  const WeekGrid({
    super.key,
    required this.days,
    required this.appointments,
    required this.showDoctor,
    required this.showPatient,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
  });

  @override
  Widget build(BuildContext context) {
    final totalHeight = (endHour - startHour) * hourHeight;

    return SizedBox(
      height: totalHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(7, (i) {
          final day = days[i];

          final dayAppointments = appointments.where((appointment) {
            return appointment.date.year == day.year &&
                appointment.date.month == day.month &&
                appointment.date.day == day.day;
          }).toList();

          return Expanded(
            child: DayColumn(
              dayIndex: i,
              appointments: dayAppointments,
              showDoctor: showDoctor,
              showPatient: showPatient,
              startHour: startHour,
              endHour: endHour,
              hourHeight: hourHeight,
            ),
          );
        }),
      ),
    );
  }
}
