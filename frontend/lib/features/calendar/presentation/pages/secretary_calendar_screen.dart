import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/utils/logout_helper.dart';
import 'package:frontend/features/calendar/presentation/providers/secretary_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/utils/calendar_dialog_helpers.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_app_bar.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_body.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_fab_menu.dart';

class SecretaryCalendarScreen extends ConsumerStatefulWidget {
  const SecretaryCalendarScreen({super.key});

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
      ref.read(secretaryCalendarNotifierProvider.notifier).refresh();
    }
  }

  Future<void> _openCreateSchedule() async {
    _closeFab();

    await showCreateScheduleSheet(context: context);
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
          ),
        ],
      ),
    );
  }
}
