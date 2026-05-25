import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/widgets/appointment_card.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/theme/calendar_theme.dart';
import 'package:frontend/theme/clinic_colors.dart';

class DayColumn extends StatelessWidget {
  final int dayIndex;
  final List<Appointment> appointments;
  final List<Schedule> schedules;
  final bool showDoctor;
  final bool showPatient;
  final int startHour;
  final int endHour;
  final double hourHeight;
  final void Function(Appointment)? onBlockadeTap;

  const DayColumn({
    super.key,
    required this.dayIndex,
    required this.appointments,
    required this.schedules,
    required this.showDoctor,
    required this.showPatient,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    this.onBlockadeTap,
  });

  double _topFromTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final totalMinutes = (hour - startHour) * 60 + minute;
    return totalMinutes * (hourHeight / 60);
  }

  double _heightFromDuration(int durationMinutes) {
    return durationMinutes * (hourHeight / 60);
  }

  // Altura de una franja de schedule en función de start/end
  double _heightFromTimeRange(String startTime, String endTime) {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    return (endMinutes - startMinutes) * (hourHeight / 60);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: dayIndex < 6
              ? BorderSide(
                  color: CalendarColors.divider(context),
                  width: CalendarSizes.dividerWidth,
                )
              : BorderSide.none,
        ),
      ),
      child: Stack(
        children: [
          // Grilla de horas (fondo)
          Column(
            children: List.generate(endHour - startHour, (_) {
              return Container(
                height: hourHeight,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CalendarColors.divider(context),
                      width: CalendarSizes.dividerWidth,
                    ),
                  ),
                ),
              );
            }),
          ),

          ...schedules.map((schedule) {
            final top = _topFromTime(schedule.startTime);
            final height =
                _heightFromTimeRange(schedule.startTime, schedule.endTime);
            final color = getClinicColor(schedule.clinicName);
            final textColor = color.withOpacity(0.75);

            return Positioned(
              top: top,
              left: 0,
              right: 0,
              height: height,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  border: Border(
                    left: BorderSide(color: color.withOpacity(0.6), width: 3),
                  ),
                ),
                padding: const EdgeInsets.only(left: 6, top: 4),
                child: Text(
                  schedule.clinicName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }),

          // Citas (encima de todo)
          ...appointments.map((appointment) {
            final top = _topFromTime(appointment.startTime);
            final height = _heightFromDuration(appointment.appointmentDuration);

            return Positioned(
              top: top,
              left: CalendarSizes.appointmentHorizontalInset,
              right: CalendarSizes.appointmentHorizontalInset,
              height: height,
              child: AppointmentCard(
                appointment: appointment,
                showDoctor: showDoctor,
                showPatient: showPatient,
                onTap: appointment.isBlockade
                    ? () => onBlockadeTap?.call(appointment)
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }
}