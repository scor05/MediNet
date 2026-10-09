import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/auth/presentation/utils/logout_helper.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';
import 'package:frontend/features/calendar/presentation/dialogs/appointment_detail_dialog.dart';
import 'package:frontend/features/calendar/presentation/dialogs/secretary_calendar_item_dialogs.dart';
import 'package:frontend/features/calendar/presentation/models/secretary_calendar_item.dart';
import 'package:frontend/features/calendar/presentation/providers/doctor_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/utils/appointment_time_utils.dart';
import 'package:frontend/features/calendar/presentation/utils/calendar_dialog_helpers.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_app_bar.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_body.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_fab_menu.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_shell.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';

class DoctorCalendarScreen extends ConsumerStatefulWidget {
  final UserProfile profile;

  const DoctorCalendarScreen({super.key, required this.profile});

  @override
  ConsumerState<DoctorCalendarScreen> createState() =>
      _DoctorCalendarScreenState();
}

class _DoctorCalendarScreenState extends ConsumerState<DoctorCalendarScreen> {
  bool _fabOpen = false;
  bool _showCancelled = true;
  int? _highlightedAppointmentId;
  Timer? _highlightDelayTimer;
  Timer? _highlightClearTimer;

  @override
  void dispose() {
    _highlightDelayTimer?.cancel();
    _highlightClearTimer?.cancel();
    super.dispose();
  }

  void _toggleFab() {
    setState(() => _fabOpen = !_fabOpen);
  }

  void _closeFab() {
    setState(() => _fabOpen = false);
  }

  void _toggleCancelled() {
    setState(() => _showCancelled = !_showCancelled);
  }

  Future<void> _openCreateAppointment() async {
    _closeFab();

    final weekStart = ref.read(doctorWeekStartProvider);

    final created = await showCreateAppointmentSheet(
      context: context,
      weekStart: weekStart,
      fixedDoctor: DoctorSearchResult(
        id: widget.profile.id,
        name: widget.profile.name,
        specialty: '',
      ),
    );

    if (created != null && mounted) {
      final createdWeekStart = calendarWeekStart(created.date);
      ref
          .read(doctorWeekStartProvider.notifier)
          .update((_) => createdWeekStart);
      await ref.read(doctorCalendarNotifierProvider.notifier).refresh();
      await _highlightCreatedAppointment(created);
    }
  }

  Future<void> _highlightCreatedAppointment(Appointment appointment) async {
    if (!mounted) return;

    // The refreshed week must complete a frame before the one-second delay
    // begins. This prevents an item from the previous week being highlighted.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    _highlightDelayTimer?.cancel();
    _highlightClearTimer?.cancel();
    _highlightDelayTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted || !_appointmentIsVisible(appointment)) return;

      setState(() => _highlightedAppointmentId = appointment.id);
      _highlightClearTimer = Timer(const Duration(seconds: 4), () {
        if (!mounted || _highlightedAppointmentId != appointment.id) return;
        setState(() => _highlightedAppointmentId = null);
      });
    });
  }

  bool _appointmentIsVisible(Appointment appointment) {
    final visibleWeek = ref.read(doctorWeekStartProvider);
    if (calendarWeekStart(appointment.date) != visibleWeek) return false;

    final appointments = ref.read(doctorCalendarNotifierProvider).asData?.value;
    return appointments?.any((item) => item.id == appointment.id) ?? false;
  }

  Future<void> _openCreateSchedule() async {
    _closeFab();

    await showCreateScheduleSheet(context: context);
  }

  Future<void> _openBlockSchedule() async {
    _closeFab();
    await showBlockScheduleSheet(context: context);
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
          .read(doctorCalendarNotifierProvider.notifier)
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
      onCancelled: ref.read(doctorCalendarNotifierProvider.notifier).refresh,
      onRescheduled: ref.read(doctorCalendarNotifierProvider.notifier).refresh,
      canReschedule: true,
      showBackupTargetDetails: true,
    );
  }

  Future<void> _openScheduleDetail(Schedule schedule) async {
    final weekStart = ref.read(doctorWeekStartProvider);
    final datedItem = SecretaryCalendarItem.fromSchedule(
      schedule.copyWith(doctorName: widget.profile.name),
      weekStart.add(Duration(days: schedule.dayOfWeek)),
    );
    await showSecretaryBackgroundItemDetails(
      context: context,
      item: datedItem,
      onEditSchedule: () => showEditScheduleSheet(
        context: context,
        schedule: schedule,
        forSecretary: false,
      ),
      onDeleteSchedule: () => ref
          .read(doctorCalendarNotifierProvider.notifier)
          .deleteSchedule(schedule.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(doctorCalendarNotifierProvider);
    final visibleCalendarAsync = calendarAsync.whenData(
      (items) => items
          .where(
            (item) =>
                (item.isBlockade || item.doctorId == widget.profile.id) &&
                (_showCancelled || !item.isCancelled),
          )
          .toList(),
    );
    final weekStart = ref.watch(doctorWeekStartProvider);

    return Scaffold(
      appBar: CalendarAppBar(
        title: 'Mi Calendario',
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => logoutAndGoToWelcome(context: context, ref: ref),
        ),
        settingsButton: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () =>
              CalendarShellNavigation.maybeOf(context)?.onOpenSettings(),
        ),
        extraActions: [
          IconButton(
            icon: Icon(
              _showCancelled ? Icons.event_busy : Icons.event_busy_outlined,
              color: _showCancelled ? null : Colors.grey,
            ),
            tooltip: _showCancelled
                ? 'Ocultar citas canceladas'
                : 'Mostrar citas canceladas',
            onPressed: _toggleCancelled,
          ),
        ],
        onPreviousWeek: () => ref
            .read(doctorWeekStartProvider.notifier)
            .update((d) => d.subtract(const Duration(days: 7))),
        onNextWeek: () => ref
            .read(doctorWeekStartProvider.notifier)
            .update((d) => d.add(const Duration(days: 7))),
      ),
      body: Stack(
        children: [
          CalendarBody(
            calendarAsync: visibleCalendarAsync,
            weekStart: weekStart,
            onRetry: ref.read(doctorCalendarNotifierProvider.notifier).refresh,
            showPatient: true,
            showSchedules: true,
            splitOverlappingAppointments: true,
            highlightedAppointmentId: _highlightedAppointmentId,
            onAppointmentTap: _openAppointmentDetail,
            onBlockadeTap: _onBlockadeTap,
            onScheduleTap: _openScheduleDetail,
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
