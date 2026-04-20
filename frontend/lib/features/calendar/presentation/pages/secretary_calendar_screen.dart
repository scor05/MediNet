import 'package:flutter/material.dart';
import '../providers/secretary_calendar_provider.dart';
import '../widgets/week_view.dart';
import 'dialogs/create_appointment_dialog.dart';

class SecretaryCalendarPage extends StatefulWidget {
  const SecretaryCalendarPage({super.key});

  @override
  State<SecretaryCalendarPage> createState() => _SecretaryCalendarPageState();
}

class _SecretaryCalendarPageState extends State<SecretaryCalendarPage> {
  late final SecretaryCalendarNotifier _notifier;
  bool _fabOpen = false;

  @override
  void initState() {
    super.initState();
    _notifier = createSecretaryCalendarNotifier();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  void _toggleFab() => setState(() => _fabOpen = !_fabOpen);
  void _closeFab() => setState(() => _fabOpen = false);

  Future<void> _openCreateAppointment() async {
    _closeFab();
    final created = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CreateAppointmentDialog(weekStart: _notifier.state.weekStart),
    );
    if (created != null) _notifier.addAppointment(created);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          IconButton(icon: const Icon(Icons.chevron_left),  onPressed: _notifier.previousWeek),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: _notifier.nextWeek),
        ],
      ),
      body: ListenableBuilder(
        listenable: _notifier,
        builder: (context, _) {
          final s = _notifier.state;

          //Obtener listas únicas de doctores/clínicas del resultado 
          final doctors = { for (final a in s.appointments) a.doctorId: a.doctorName }
              .entries
              .where((e) => e.key != null)
              .toList();
          final clinics = s.appointments.map((a) => a.clinicName).toSet().toList();

          return Stack(
            children: [
              Column(
                children: [
                  
                  _FilterBar(
                    doctors: doctors,
                    clinics: clinics,
                    selectedDoctorId: s.filterDoctorId,
                    selectedClinic: clinics.isNotEmpty &&
                            s.filterClinicId != null
                        ? clinics.first 
                        : null,
                    onDoctorChanged: _notifier.setDoctorFilter,
                    onClinicChanged: (_) {}, 
                  ),

                  // ── Contenido ────────────────────────────────────────────
                  Expanded(
                    child: s.loading
                        ? const Center(child: CircularProgressIndicator())
                        : s.error != null
                            ? _ErrorView(
                                message: s.error!,
                                onRetry: _notifier.load,
                              )
                            : WeekView(
                                weekStart: s.weekStart,
                                appointments: s.appointments,
                                showDoctor: true,  
                              ),
                  ),
                ],
              ),

              // ── FAB overlay ──────────────────────────────────────────────
              if (_fabOpen)
                GestureDetector(
                  onTap: _closeFab,
                  child: Container(color: Colors.black26),
                ),
              _buildFab(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFab() {
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
            const SizedBox(height: 12),
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

// Widgets privados


class _FilterBar extends StatelessWidget {
  final List<MapEntry<int?, String?>> doctors;
  final List<String> clinics;
  final int? selectedDoctorId;
  final String? selectedClinic;
  final ValueChanged<int?> onDoctorChanged;
  final ValueChanged<String?> onClinicChanged;

  const _FilterBar({
    required this.doctors,
    required this.clinics,
    required this.selectedDoctorId,
    required this.selectedClinic,
    required this.onDoctorChanged,
    required this.onClinicChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int?>(
              value: selectedDoctorId,
              decoration: const InputDecoration(
                labelText: 'Doctor',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todos')),
                ...doctors.map(
                  (e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value ?? '—', overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              onChanged: onDoctorChanged,
            ),
          ),
          const SizedBox(width: 12),
          // Filtro Clínica (por nombre por ahora)
          Expanded(
            child: DropdownButtonFormField<String?>(
              value: selectedClinic,
              decoration: const InputDecoration(
                labelText: 'Clínica',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas')),
                ...clinics.map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              onChanged: onClinicChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
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
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
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
