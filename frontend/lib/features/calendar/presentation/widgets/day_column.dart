import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/widgets/appointment_card.dart';
import 'package:frontend/theme/calendar_theme.dart';

class DayColumn extends StatelessWidget {
  final int dayIndex;
  final List<Appointment> appointments;
  final bool showDoctor;
  final bool showPatient;
  final int startHour;
  final int endHour;
  final double hourHeight;

  const DayColumn({
    super.key,
    required this.dayIndex,
    required this.appointments,
    required this.showDoctor,
    required this.showPatient,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
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
              ),
            );
          }),
        ],
      ),
    );
  }
}
