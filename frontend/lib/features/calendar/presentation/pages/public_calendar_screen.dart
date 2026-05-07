import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/calendar/domain/entities/public_slot.dart';
import 'package:frontend/features/calendar/presentation/pages/dialogs/public_create_appointment_dialog.dart';
import 'package:frontend/features/calendar/presentation/providers/public_calendar_provider.dart';

class PublicCalendarScreen extends ConsumerStatefulWidget {
  final int? initialDoctorId;
  final int? initialClinicId;

  const PublicCalendarScreen({
    super.key,
    this.initialDoctorId,
    this.initialClinicId,
  });

  @override
  ConsumerState<PublicCalendarScreen> createState() =>
      _PublicCalendarScreenState();
}

class _PublicCalendarScreenState extends ConsumerState<PublicCalendarScreen> {
  bool _contextApplied = false;

  Future<void> _openCreateAppointment() async {
    final selectedSlot = await showModalBottomSheet<PublicSlot>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const PublicCreateAppointmentDialog(),
    );

    if (selectedSlot != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Horario seleccionado: ${selectedSlot.startTime}'),
        ),
      );
    }
  }

  void _applyInitialContext() {
    if (_contextApplied) return;
    if (widget.initialDoctorId == null && widget.initialClinicId == null) {
      _contextApplied = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(publicCalendarNotifierProvider.notifier)
          .setActiveContext(
            doctorId: widget.initialDoctorId,
            clinicId: widget.initialClinicId,
          );
    });
    _contextApplied = true;
  }

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(publicCalendarNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario público')),
      body: calendarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e is ApiException ? e.message : 'Error inesperado.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: ref
                    .read(publicCalendarNotifierProvider.notifier)
                    .refresh,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (state) {
          _applyInitialContext();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agenda una cita médica',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Selecciona una combinación de doctor, clínica y fecha para ver horarios disponibles.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                if (state.doctors.isNotEmpty)
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Doctor activo',
                    ),
                    child: Text(
                      state.doctors
                          .firstWhere(
                            (doctor) => doctor.id == state.activeDoctorId,
                            orElse: () => state.doctors.first,
                          )
                          .name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 10),
                if (state.clinics.isNotEmpty)
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Clínica activa',
                    ),
                    child: Text(
                      state.clinics
                          .firstWhere(
                            (clinic) => clinic.id == state.activeClinicId,
                            orElse: () => state.clinics.first,
                          )
                          .name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _openCreateAppointment,
                    child: const Text('Agendar cita'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
