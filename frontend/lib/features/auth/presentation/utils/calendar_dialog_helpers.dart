import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/dialogs/create_appointment_dialog.dart';
import 'package:frontend/features/calendar/presentation/dialogs/create_schedule_dialog.dart';

Future<Appointment?> showCreateAppointmentSheet({
  required BuildContext context,
  required DateTime weekStart,
}) {
  return showModalBottomSheet<Appointment>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => CreateAppointmentDialog(weekStart: weekStart),
  );
}

Future<void> showCreateScheduleSheet({required BuildContext context}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const CreateScheduleDialog(),
  );
}
