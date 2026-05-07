import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/theme/calendar_theme.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool showDoctor;
  final bool showPatient;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.showDoctor = false,
    this.showPatient = false,
  });

  Color _statusColor() {
    return switch (appointment.status) {
      'accepted' => CalendarColors.appointmentAccepted,
      'requested' => CalendarColors.appointmentRequested,
      'cancelled' => CalendarColors.appointmentCancelled,
      _ => CalendarColors.appointmentUnknown,
    };
  }

  String _formatTime(String time) {
    final parts = time.split(':');

    final hour = int.parse(parts[0]);
    final minute = parts[1];

    if (hour == 0) return '12:$minute AM';
    if (hour < 12) return '$hour:$minute AM';
    if (hour == 12) return '12:$minute PM';
    return '${hour - 12}:$minute PM';
  }

  String _calculateEndTime(String startTime, int durationMinutes) {
    final parts = startTime.split(':');

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final second = int.parse(parts[2]);

    final startDateTime = DateTime(2026, 1, 1, hour, minute, second);

    final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));

    return '${endDateTime.hour}:${endDateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _statusColor(),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDoctor)
              Text(
                appointment.doctorName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            if (showPatient)
              Text(
                appointment.patientName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            Text(
              '${_formatTime(appointment.startTime)} - ${_calculateEndTime(appointment.startTime, appointment.appointmentDuration)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
