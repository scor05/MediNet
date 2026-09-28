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
  final bool splitOverlappingAppointments;
  final int startHour;
  final int endHour;
  final double hourHeight;
  final void Function(Appointment)? onBlockadeTap;
  final void Function(Appointment)? onAppointmentTap;
  final void Function(Schedule)? onScheduleTap;

  const DayColumn({
    super.key,
    required this.dayIndex,
    required this.appointments,
    required this.schedules,
    required this.showDoctor,
    required this.showPatient,
    this.splitOverlappingAppointments = false,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    this.onAppointmentTap,
    this.onBlockadeTap,
    this.onScheduleTap,
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

  int _minutesFromTime(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  List<_AppointmentPlacement> _appointmentPlacements(List<Appointment> items) {
    if (items.isEmpty) return const [];

    final sorted = [...items]
      ..sort((first, second) {
        final firstStart = _minutesFromTime(first.startTime);
        final secondStart = _minutesFromTime(second.startTime);
        final startComparison = firstStart.compareTo(secondStart);
        if (startComparison != 0) return startComparison;
        return first.appointmentDuration.compareTo(second.appointmentDuration);
      });
    final placements = <_AppointmentPlacement>[];
    var cluster = <Appointment>[];
    var clusterEnd = -1;

    void placeCluster() {
      if (cluster.isEmpty) return;
      final columnEnds = <int>[];
      final columns = <Appointment, int>{};

      for (final appointment in cluster) {
        final start = _minutesFromTime(appointment.startTime);
        final end = start + appointment.appointmentDuration;
        var column = columnEnds.indexWhere((columnEnd) => columnEnd <= start);
        if (column == -1) {
          column = columnEnds.length;
          columnEnds.add(end);
        } else {
          columnEnds[column] = end;
        }
        columns[appointment] = column;
      }

      for (final appointment in cluster) {
        placements.add(
          _AppointmentPlacement(
            appointment: appointment,
            column: columns[appointment]!,
            columnCount: columnEnds.length,
          ),
        );
      }
    }

    for (final appointment in sorted) {
      final start = _minutesFromTime(appointment.startTime);
      final end = start + appointment.appointmentDuration;
      if (cluster.isNotEmpty && start >= clusterEnd) {
        placeCluster();
        cluster = [];
        clusterEnd = -1;
      }
      cluster.add(appointment);
      if (end > clusterEnd) clusterEnd = end;
    }
    placeCluster();

    return placements;
  }

  Widget _appointmentCard(Appointment appointment) {
    return AppointmentCard(
      appointment: appointment,
      showDoctor: showDoctor,
      showPatient: showPatient,
      onTap: appointment.isBlockade
          ? () => onBlockadeTap?.call(appointment)
          : () => onAppointmentTap?.call(appointment),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blockades = appointments.where((item) => item.isBlockade).toList();
    final regularAppointments = appointments
        .where((item) => !item.isBlockade)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) => Container(
        key: ValueKey('calendar-day-column-$dayIndex'),
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
              final height = _heightFromTimeRange(
                schedule.startTime,
                schedule.endTime,
              );
              final color = getClinicColor(schedule.clinicName);
              final textColor = color.withOpacity(0.75);

              return Positioned(
                top: top,
                left: CalendarSizes.calendarItemDayEdgeInset,
                right: CalendarSizes.calendarItemDayEdgeInset,
                height: height,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onScheduleTap == null
                        ? null
                        : () => onScheduleTap!(schedule),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        border: Border(
                          left: BorderSide(
                            color: color.withOpacity(0.6),
                            width: 3,
                          ),
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
                  ),
                ),
              );
            }),

            // Los bloqueos conservan el ancho completo y no participan en las
            // columnas de colisión de las citas del doctor.
            ...blockades.map((appointment) {
              final top = _topFromTime(appointment.startTime);
              final height = _heightFromDuration(
                appointment.appointmentDuration,
              );

              return Positioned(
                key: ValueKey('calendar-blockade-${appointment.id}'),
                top: top,
                left: CalendarSizes.calendarItemDayEdgeInset,
                right: CalendarSizes.calendarItemDayEdgeInset,
                height: height,
                child: _appointmentCard(appointment),
              );
            }),

            // Solo el calendario del doctor habilita columnas lado a lado.
            ..._appointmentPlacements(regularAppointments).map((placement) {
              final appointment = placement.appointment;
              final top = _topFromTime(appointment.startTime);
              final height = _heightFromDuration(
                appointment.appointmentDuration,
              );
              const gap = 2.0;
              final edgeInset = CalendarSizes.calendarItemDayEdgeInset;
              final columnCount = splitOverlappingAppointments
                  ? placement.columnCount
                  : 1;
              final column = splitOverlappingAppointments
                  ? placement.column
                  : 0;
              final usableWidth = constraints.maxWidth - edgeInset * 2;
              final width =
                  (usableWidth - gap * (columnCount - 1)) / columnCount;
              final left = edgeInset + column * (width + gap);

              return Positioned(
                key: ValueKey('calendar-appointment-${appointment.id}'),
                top: top,
                left: left,
                width: width,
                height: height,
                child: _appointmentCard(appointment),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _AppointmentPlacement {
  final Appointment appointment;
  final int column;
  final int columnCount;

  const _AppointmentPlacement({
    required this.appointment,
    required this.column,
    required this.columnCount,
  });
}
