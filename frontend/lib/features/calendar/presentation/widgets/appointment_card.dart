import 'package:flutter/material.dart';
import 'package:frontend/core/utils/time_format.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_item_content.dart';
import 'package:frontend/theme/calendar_theme.dart';

Color appointmentStatusColor(String status) {
  return switch (status) {
    'accepted' => CalendarColors.appointmentAccepted,
    'requested' => CalendarColors.appointmentRequested,
    'backup_pending' => CalendarColors.appointmentRequested,
    'backup_accepted' => CalendarColors.appointmentAccepted,
    'backup_cancelled' => CalendarColors.appointmentCancelled,
    'cancelled' => CalendarColors.appointmentCancelled,
    _ => CalendarColors.appointmentUnknown,
  };
}

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

  String get _timeRange =>
      '${formatTime24(appointment.startTime)}–'
      '${calculateEndTime24(appointment.startTime, appointment.appointmentDuration)}';

  @override
  Widget build(BuildContext context) {
    if (appointment.isBlockade) {
      return GestureDetector(onTap: onTap, child: _buildBlockadeCard());
    }
    final person = showPatient
        ? appointment.patientName
        : (showDoctor ? appointment.doctorName : null);

    return Card(
      color: appointmentStatusColor(appointment.status),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: CalendarItemContent(
          type: 'Cita',
          person: person,
          clinic: appointment.clinicName,
          timeRange: _timeRange,
          color: Colors.black87,
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
        child: SizedBox.expand(
          child: CalendarItemContent(
            type: 'Bloqueo',
            person: showDoctor ? appointment.doctorName : null,
            clinic: appointment.clinicName,
            timeRange: _timeRange,
            color: Colors.white,
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
