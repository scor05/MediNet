import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';
import 'package:frontend/features/auth/presentation/utils/logout_helper.dart';
import 'package:frontend/features/calendar/presentation/dialogs/appointment_detail_dialog.dart';
import 'package:frontend/features/calendar/presentation/providers/secretary_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/providers/secretary_requested_appointments_provider.dart';
import 'package:frontend/features/calendar/presentation/utils/calendar_dialog_helpers.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_app_bar.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_body.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_fab_menu.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_shell.dart';

class SecretaryCalendarScreen extends ConsumerStatefulWidget {
  final UserProfile profile;

  const SecretaryCalendarScreen({super.key, required this.profile});

  @override
  ConsumerState<SecretaryCalendarScreen> createState() =>
      _SecretaryCalendarScreenState();
}

class _SecretaryCalendarScreenState
    extends ConsumerState<SecretaryCalendarScreen> {
  bool _fabOpen = false;

  void _toggleFab() {
    setState(() => _fabOpen = !_fabOpen);
  }

  void _closeFab() {
    setState(() => _fabOpen = false);
  }

  Future<void> _openCreateAppointment() async {
    _closeFab();

    final weekStart = ref.read(secretaryWeekStartProvider);

    final created = await showCreateAppointmentSheet(
      context: context,
      weekStart: weekStart,
    );

    if (created != null) {
      await Future.wait([
        ref.read(secretaryCalendarNotifierProvider.notifier).refresh(),
        ref
            .read(secretaryRequestedAppointmentsNotifierProvider.notifier)
            .refresh(),
      ]);
    }
  }

  Future<void> _openCreateSchedule() async {
    _closeFab();

    await showCreateScheduleSheet(context: context);
  }

  Future<void> _openBlockSchedule() async {
    _closeFab();
    await showBlockScheduleSecretarySheet(context: context);
  }

  Future<void> _onBlockadeTap(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar bloqueo'),
        content: const Text('¿Deseas eliminar este bloqueo de horario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref
          .read(secretaryCalendarNotifierProvider.notifier)
          .deleteBlockade(appointment.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bloqueo eliminado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _openAppointmentDetail(Appointment appointment) {
    showAppointmentDetailSheet(
      context: context,
      appointment: appointment,
      onCancelled: ref.read(secretaryCalendarNotifierProvider.notifier).refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(secretaryCalendarNotifierProvider);
    final weekStart = ref.watch(secretaryWeekStartProvider);

    return Scaffold(
      appBar: CalendarAppBar(
        title: 'Calendario de citas',
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => logoutAndGoToWelcome(context: context, ref: ref),
        ),
        settingsButton: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () =>
              CalendarShellNavigation.maybeOf(context)?.onOpenSettings(),
        ),
        onPreviousWeek: () => ref
            .read(secretaryWeekStartProvider.notifier)
            .update((d) => d.subtract(const Duration(days: 7))),
        onNextWeek: () => ref
            .read(secretaryWeekStartProvider.notifier)
            .update((d) => d.add(const Duration(days: 7))),
      ),
      body: Stack(
        children: [
          CalendarBody(
            calendarAsync: calendarAsync,
            weekStart: weekStart,
            onRetry: ref
                .read(secretaryCalendarNotifierProvider.notifier)
                .refresh,
            onAppointmentTap: _openAppointmentDetail,
            onBlockadeTap: _onBlockadeTap,
          ),
          if (_fabOpen)
            GestureDetector(
              onTap: _closeFab,
              child: Container(color: Colors.black26),
            ),
          CalendarFabMenu(
            isOpen: _fabOpen,
            onToggle: _toggleFab,
            onCreateAppointment: _openCreateAppointment,
            onCreateSchedule: _openCreateSchedule,
            onBlockSchedule: _openBlockSchedule,
          ),
        ],
      ),
    );
  }
}
