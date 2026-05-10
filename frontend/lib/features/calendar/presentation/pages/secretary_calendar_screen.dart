import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';
import 'package:frontend/features/auth/presentation/utils/logout_helper.dart';
import 'package:frontend/features/calendar/presentation/providers/secretary_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/providers/secretary_pending_appointments_provider.dart';

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
      ref.read(secretaryCalendarNotifierProvider.notifier).refresh();
      ref.read(secretaryPendingAppointmentsNotifierProvider.notifier).refresh();
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
        settingsButton: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(profile: widget.profile),
              ),
            );
          },
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

class _FabMenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FabMenuItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          heroTag: label,
          backgroundColor: color,
          onPressed: onTap,
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ],
    );
  }
}
