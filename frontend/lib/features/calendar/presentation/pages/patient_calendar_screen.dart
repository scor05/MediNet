import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/patient_calendar_provider.dart';
import '../widgets/week_view.dart';

class PatientCalendarPage extends ConsumerWidget {
  const PatientCalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(patientCalendarProvider);
    final notifier = ref.read(patientCalendarProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis citas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: notifier.previousWeek,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: notifier.nextWeek,
          ),
        ],
      ),
      body: _buildBody(s, notifier),
    );
  }

  Widget _buildBody(PatientCalendarState s, PatientCalendarNotifier notifier) {
    if (s.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (s.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.error!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: notifier.load,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (s.appointments.isEmpty) {
      return const Center(
        child: Text(
          'No tienes citas esta semana.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return WeekView(
      weekStart: s.weekStart,
      appointments: s.appointments,
      showDoctor: true,
    );
  }
}
