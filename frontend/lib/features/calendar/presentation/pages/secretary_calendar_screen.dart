import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/core/widgets/error_view.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';
import 'package:frontend/features/auth/presentation/utils/logout_helper.dart';
import 'package:frontend/features/calendar/presentation/dialogs/appointment_detail_dialog.dart';
import 'package:frontend/features/calendar/presentation/dialogs/secretary_calendar_item_dialogs.dart';
import 'package:frontend/features/calendar/presentation/models/secretary_calendar_item.dart';
import 'package:frontend/features/calendar/presentation/providers/secretary_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/providers/secretary_requested_appointments_provider.dart';
import 'package:frontend/features/calendar/presentation/utils/calendar_dialog_helpers.dart';
import 'package:frontend/features/calendar/presentation/utils/secretary_doctor_color.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_app_bar.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_fab_menu.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_shell.dart';
import 'package:frontend/features/calendar/presentation/widgets/secretary_calendar_view.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

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
  final _random = Random();
  final _doctorColors = <int, Color>{};

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

    await showCreateScheduleSheet(context: context, forSecretary: true);
    if (!mounted) return;
    await ref.read(secretarySchedulesNotifierProvider.notifier).refresh();
  }

  Future<void> _openBlockSchedule() async {
    _closeFab();
    await showBlockScheduleSecretarySheet(context: context);
  }

  void _openAppointmentDetail(Appointment appointment) {
    showAppointmentDetailSheet(
      context: context,
      appointment: appointment,
      onCancelled: ref.read(secretaryCalendarNotifierProvider.notifier).refresh,
      onRescheduled: ref
          .read(secretaryCalendarNotifierProvider.notifier)
          .refresh,
      canReschedule: true,
    );
  }

  Future<void> _openCalendarItems(List<SecretaryCalendarItem> items) async {
    if (items.isEmpty) return;
    final selected = items.length == 1
        ? items.first
        : await showSecretaryCalendarItemChooser(
            context: context,
            items: items,
          );
    if (selected == null || !mounted) return;

    if (selected.type == SecretaryCalendarItemType.appointment) {
      _openAppointmentDetail(selected.appointment!);
      return;
    }

    await showSecretaryBackgroundItemDetails(
      context: context,
      item: selected,
      onDeleteBlockade: selected.type == SecretaryCalendarItemType.blockade
          ? () => ref
                .read(secretaryCalendarNotifierProvider.notifier)
                .deleteBlockade(selected.appointment!.id)
          : null,
      onEditSchedule: selected.type == SecretaryCalendarItemType.schedule
          ? () => showEditScheduleSheet(
              context: context,
              schedule: selected.schedule!,
              forSecretary: true,
            )
          : null,
      onDeleteSchedule: selected.type == SecretaryCalendarItemType.schedule
          ? () => ref
                .read(secretaryCalendarNotifierProvider.notifier)
                .deleteSchedule(selected.schedule!.id)
          : null,
    );
  }

  void _ensureDoctorColors(
    List<Appointment> appointments,
    List<Schedule> schedules,
  ) {
    final doctorIds = <int>{
      ...appointments.map((item) => item.doctorId),
      ...schedules.map((item) => item.doctorId),
    }..remove(0);

    for (final doctorId in doctorIds) {
      _doctorColors.putIfAbsent(
        doctorId,
        () => generateSecretaryDoctorColor(
          _random,
          assignedColors: _doctorColors.values,
        ),
      );
    }
  }

  Future<void> _refreshCalendar() async {
    await Future.wait([
      ref.read(secretaryCalendarNotifierProvider.notifier).refresh(),
      ref.read(secretarySchedulesNotifierProvider.notifier).refresh(),
    ]);
  }

  Widget _calendarContent(
    AsyncValue<List<Appointment>> calendarAsync,
    AsyncValue<List<Schedule>> schedulesAsync,
    DateTime weekStart,
  ) {
    final appointments = calendarAsync.asData?.value;
    final schedules = schedulesAsync.asData?.value;

    if (appointments == null || schedules == null) {
      final error = calendarAsync.error ?? schedulesAsync.error;
      if (error != null) {
        return ErrorView(
          message: error is ApiException ? error.message : 'Error inesperado.',
          onRetry: _refreshCalendar,
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    _ensureDoctorColors(appointments, schedules);
    return Stack(
      children: [
        SecretaryCalendarView(
          weekStart: weekStart,
          appointments: appointments,
          schedules: schedules,
          doctorColors: _doctorColors,
          onItemsTap: _openCalendarItems,
        ),
        if (calendarAsync.isLoading || schedulesAsync.isLoading)
          const LinearProgressIndicator(minHeight: 3),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(secretaryCalendarNotifierProvider);
    final schedulesAsync = ref.watch(secretarySchedulesNotifierProvider);
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
          _calendarContent(calendarAsync, schedulesAsync, weekStart),
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
