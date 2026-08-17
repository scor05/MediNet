import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/theme/calendar_theme.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool showDoctor;
  final bool showPatient;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.showDoctor = false,
    this.showPatient = false,
    this.onTap,
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
    final second = parts.length > 2 ? int.parse(parts[2]) : 0;
    final endDateTime = DateTime(
      2026,
      1,
      1,
      hour,
      minute,
      second,
    ).add(Duration(minutes: durationMinutes));
    return '${endDateTime.hour}:${endDateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (appointment.isBlockade) {
      return GestureDetector(onTap: onTap, child: _buildBlockadeCard());
    }
    return Card(
      color: _statusColor(),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDoctor)
                Text(
                  appointment.doctorName,
                  style: CalendarTextStyles.appointmentTime,
                ),
              if (showPatient)
                Text(
                  appointment.patientName,
                  style: CalendarTextStyles.appointmentTime,
                ),
              Text(
                '${_formatTime(appointment.startTime)} - ${_calculateEndTime(appointment.startTime, appointment.appointmentDuration)}',
                style: CalendarTextStyles.appointmentPatient,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockadeCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: CustomPaint(
        painter: _StripePainter(
          base: CalendarColors.appointmentBlockade,
          stripe: CalendarColors.appointmentBlockadeStripe,
        ),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.block, size: 10, color: Colors.white70),
                  const SizedBox(width: 4),
                  const Text(
                    'Bloqueado',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                '${_formatTime(appointment.startTime)} - ${_calculateEndTime(appointment.startTime, appointment.appointmentDuration)}',
                style: const TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  final Color base;
  final Color stripe;

  const _StripePainter({required this.base, required this.stripe});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = base);

    final paint = Paint()
      ..color = stripe
      ..strokeWidth = 4;

    const step = 10.0;
    for (double i = -size.height; i < size.width + size.height; i += step) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) =>
      old.base != base || old.stripe != stripe;
}
