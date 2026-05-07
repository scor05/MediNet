import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/widgets/time_column.dart';
import 'package:frontend/features/calendar/presentation/widgets/week_grid.dart';
import 'package:frontend/features/calendar/presentation/widgets/week_header.dart';

class WeekView extends StatelessWidget {
  final DateTime weekStart;
  final List<Appointment> appointments;
  final bool showDoctor;
  final bool showPatient;

  const WeekView({
    super.key,
    required this.weekStart,
    required this.appointments,
    this.showDoctor = false,
    this.showPatient = false,
  });

  static const int startHour = 0;
  static const int endHour = 24;
  static const double hourHeight = 80;
  static const double timeColumnWidth = 100;

  @override
  Widget build(BuildContext context) {
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
                    showDoctor: showDoctor,
                    showPatient: showPatient,
                    startHour: startHour,
                    endHour: endHour,
                    hourHeight: hourHeight,
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
