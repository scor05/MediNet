import 'package:flutter/material.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/usecases/get_doctor_appointments.dart';
import '../../data/datasources/appointment_remote_datasource.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../widgets/week_view.dart';
import 'dialogs/create_clinic_dialog.dart';
import 'dialogs/create_schedule_dialog.dart';
import 'dialogs/create_appointment_dialog.dart';
import 'package:frontend/core/exceptions/api_exception.dart';

class DoctorCalendarPage extends StatefulWidget {
  const DoctorCalendarPage({super.key});

  @override
  State<DoctorCalendarPage> createState() => _DoctorCalendarPageState();
}

class _DoctorCalendarPageState extends State<DoctorCalendarPage> {
  final _getCalendarUsecase = GetDoctorCalendar(
    AppointmentRepositoryImpl(AppointmentRemoteDatasource()),
  );

  // Estado
  late DateTime _weekStart;
  List<Appointment> _appointments = [];
  bool _loading = true;
  String? _error;
  bool _fabOpen = false;

  @override
  void initState() {
    super.initState();
    _weekStart = _getMonday(DateTime.now());
    _loadAppointments();
  }

  DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dateFrom = _weekStart;
      final dateTo = _weekStart.add(const Duration(days: 6));
      final result = await _getCalendarUsecase(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      setState(() => _appointments = result);
    } catch (e, st) {
      debugPrint('Error loading appointments: $e');
      debugPrintStack(stackTrace: st);

      if (e is ApiException) {
        setState(() {
          _appointments = [];
          _error = e.message;
        });
      } else {
        setState(() {
          _appointments = [];
          _error = 'Ocurrió un error inesperado.';
        });
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void _previousWeek() {
    setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
    _loadAppointments();
  }

  void _nextWeek() {
    setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));
    _loadAppointments();
  }

  void _toggleFab() => setState(() => _fabOpen = !_fabOpen);
  void _closeFab() => setState(() => _fabOpen = false);

  Future<void> _openCreateClinic() async {
    _closeFab();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const CreateClinicDialog(),
    );
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

  Future<void> _openCreateAppointment() async {
    _closeFab();
    final created = await showModalBottomSheet<Appointment>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CreateAppointmentDialog(weekStart: _weekStart),
    );
    if (created != null) {
      // Agrega la cita localmente para retroalimentación inmediata, luego recarga desde el servidor
      setState(() => _appointments = [..._appointments, created]);
      _loadAppointments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Calendario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousWeek,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextWeek,
          ),
        ],
      ),
      body: Stack(
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadAppointments,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : WeekView(weekStart: _weekStart, appointments: _appointments),
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
            const SizedBox(height: 8),
            _FabMenuItem(
              label: 'Nueva clínica',
              icon: Icons.local_hospital_outlined,
              color: Colors.deepPurple,
              onTap: _openCreateClinic,
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
