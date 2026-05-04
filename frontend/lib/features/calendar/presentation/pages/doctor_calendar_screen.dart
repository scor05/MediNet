import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/auth/presentation/pages/welcome_screen.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/calendar/presentation/pages/dialogs/create_appointment_dialog.dart';
import 'package:frontend/features/calendar/presentation/pages/dialogs/create_schedule_dialog.dart';
import 'package:frontend/features/calendar/presentation/providers/doctor_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/widgets/week_view.dart';

class DoctorCalendarScreen extends ConsumerStatefulWidget {
  const DoctorCalendarScreen({super.key});

  @override
  ConsumerState<DoctorCalendarScreen> createState() =>
      _DoctorCalendarScreenState();
}

class _DoctorCalendarScreenState extends ConsumerState<DoctorCalendarScreen> {
  bool _fabOpen = false;

  void _toggleFab() => setState(() => _fabOpen = !_fabOpen);
  void _closeFab() => setState(() => _fabOpen = false);

  Future<void> _logout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  Future<void> _openCreateAppointment() async {
    _closeFab();
    final weekStart = ref.read(doctorWeekStartProvider);
    final created = await showModalBottomSheet<Appointment>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CreateAppointmentDialog(weekStart: weekStart),
    );
    if (created != null) {
      ref.read(doctorCalendarNotifierProvider.notifier).refresh();
    }
  }

  Future<void> _openCreateSchedule() async {
    _closeFab();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const CreateScheduleDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(doctorCalendarNotifierProvider);
    final weekStart = ref.watch(doctorWeekStartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Calendario'),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _logout,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref
                .read(doctorWeekStartProvider.notifier)
                .update((d) => d.subtract(const Duration(days: 7))),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref
                .read(doctorWeekStartProvider.notifier)
                .update((d) => d.add(const Duration(days: 7))),
          ),
        ],
      ),
      body: Stack(
        children: [
          calendarAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e is ApiException ? e.message : 'Error inesperado.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: ref
                        .read(doctorCalendarNotifierProvider.notifier)
                        .refresh,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
            data: (appointments) =>
                WeekView(weekStart: weekStart, appointments: appointments),
          ),
          if (_fabOpen)
            GestureDetector(
              onTap: _closeFab,
              child: Container(color: Colors.black26),
            ),
          _buildFab(context),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_fabOpen) ...[
            _FabMenuItem(
              label: 'Nueva cita',
              icon: Icons.event_available,
              color: Colors.green.shade700,
              onTap: _openCreateAppointment,
            ),
            const SizedBox(height: 8),
            _FabMenuItem(
              label: 'Nuevo horario',
              icon: Icons.schedule,
              color: Colors.orange.shade700,
              onTap: _openCreateSchedule,
            ),
          ],
          FloatingActionButton(
            onPressed: _toggleFab,
            child: AnimatedRotation(
              turns: _fabOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.add),
            ),
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