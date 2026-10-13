import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/models/secretary_calendar_item.dart';
import 'package:frontend/features/calendar/presentation/utils/calendar_item_icons.dart';
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

  @override
  Widget build(BuildContext context) {
    if (appointment.isBlockade) {
      return GestureDetector(onTap: onTap, child: _buildBlockadeCard());
    }
    final label = showPatient
        ? appointment.patientName
        : showDoctor
        ? appointment.doctorName
        : appointment.patientName;
    return Card(
      color: appointmentStatusColor(appointment.status),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                calendarItemIcon(SecretaryCalendarItemType.appointment),
                size: 13,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: CalendarTextStyles.appointmentTime,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                calendarItemIcon(SecretaryCalendarItemType.blockade),
                size: 13,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Bloqueo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: CalendarTextStyles.appointmentTime.copyWith(
                    color: Colors.white,
                  ),
                ),
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
