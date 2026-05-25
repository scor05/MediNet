import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/widgets/time_column.dart';
import 'package:frontend/features/calendar/presentation/widgets/week_grid.dart';
import 'package:frontend/features/calendar/presentation/widgets/week_header.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

class WeekView extends StatelessWidget {
  final DateTime weekStart;
  final List<Appointment> appointments;
  final List<Schedule> schedules;
  final bool showDoctor;
  final bool showPatient;
  final bool compact;
  final void Function(Appointment)? onBlockadeTap;

  const WeekView({
    super.key,
    required this.weekStart,
    required this.appointments,
    required this.schedules,
    this.showDoctor = false,
    this.showPatient = false,
    this.compact = false,
    this.onBlockadeTap,
  });

  static const int startHour = 6;
  static const int endHour = 18;

  @override
  Widget build(BuildContext context) {
    final double hourHeight = compact ? 52 : 80;
    final double timeColumnWidth = compact ? 48 : 100;
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Column(
      children: [
        WeekHeader(days: days, timeColumnWidth: timeColumnWidth),
        Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TimeColumn(
                  startHour: startHour,
                  endHour: endHour,
                  hourHeight: hourHeight,
                  width: timeColumnWidth,
                ),
                Expanded(
                  child: WeekGrid(
                    days: days,
                    appointments: appointments,
                    schedules: schedules,
                    showDoctor: showDoctor,
                    showPatient: showPatient,
                    startHour: startHour,
                    endHour: endHour,
                    hourHeight: hourHeight,
                    onBlockadeTap: onBlockadeTap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}