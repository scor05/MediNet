import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/widgets/day_column.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

class WeekGrid extends StatelessWidget {
  final List<DateTime> days;
  final List<Appointment> appointments;
  final List<Schedule> schedules;
  final bool showDoctor;
  final bool showPatient;
  final int startHour;
  final int endHour;
  final double hourHeight;

  const WeekGrid({
    super.key,
    required this.days,
    required this.appointments,
    required this.schedules,
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

          final dayAppointments = appointments.where((a) {
            return a.date.year == day.year &&
                a.date.month == day.month &&
                a.date.day == day.day;
          }).toList();

          // dayOfWeek en la BD es 0=lunes…6=domingo, igual que el índice i
          final daySchedules = schedules
              .where((s) => s.dayOfWeek == i)
              .toList();

          return Expanded(
            child: DayColumn(
              dayIndex: i,
              appointments: dayAppointments,
              schedules: daySchedules,
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