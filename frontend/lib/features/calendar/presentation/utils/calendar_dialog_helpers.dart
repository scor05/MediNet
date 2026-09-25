import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/dialogs/block_schedule_dialog.dart';
import 'package:frontend/features/calendar/presentation/dialogs/block_schedule_secretary_dialog.dart';
import 'package:frontend/features/calendar/presentation/dialogs/create_appointment_dialog.dart';
import 'package:frontend/features/calendar/presentation/dialogs/create_schedule_dialog.dart';
import 'package:frontend/features/calendar/presentation/dialogs/edit_schedule_dialog.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

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

Future<void> showCreateScheduleSheet({
  required BuildContext context,
  bool forSecretary = false,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => CreateScheduleDialog(forSecretary: forSecretary),
  );
}

Future<void> showEditScheduleSheet({
  required BuildContext context,
  required Schedule schedule,
  required bool forSecretary,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) =>
        EditScheduleDialog(schedule: schedule, forSecretary: forSecretary),
  );
}

Future<void> showBlockScheduleSheet({required BuildContext context}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const BlockScheduleDialog(),
  );
}

Future<void> showBlockScheduleSecretarySheet({required BuildContext context}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const BlockScheduleSecretaryDialog(),
  );
}
