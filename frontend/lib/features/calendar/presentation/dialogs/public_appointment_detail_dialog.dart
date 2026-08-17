import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/appointment/domain/providers/appointment_domain_providers.dart';
import 'package:frontend/features/calendar/presentation/providers/public_calendar_provider.dart';
import 'package:frontend/theme/calendar_theme.dart';

class PublicAppointmentDetailDialog extends ConsumerWidget {
  final Appointment appointment;

  const PublicAppointmentDetailDialog({super.key, required this.appointment});

  Color _statusColor() {
    return switch (appointment.status) {
      'accepted' => CalendarColors.appointmentAccepted,
      'requested' => CalendarColors.appointmentRequested,
      'cancelled' => CalendarColors.appointmentCancelled,
      _ => CalendarColors.appointmentUnknown,
    };
  }

  String _statusLabel() {
    return switch (appointment.status) {
      'accepted' => 'Aceptada',
      'requested' => 'Solicitada',
      'cancelled' => 'Cancelada',
      _ => appointment.status,
    };
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _formatTime(String time) {
    final parts = time.split(':');

    final hour = int.parse(parts[0]);
    final minute = parts[1];

    if (hour == 0) return '12:$minute AM';
    if (hour < 12) return '$hour:$minute AM';
    if (hour == 12) return '12:$minute PM';

    return '${hour - 12}:$minute PM';
  }

  String _calculateEndTime(String startTime, int durationMinutes) {
    final parts = startTime.split(':');

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final second = parts.length > 2 ? int.parse(parts[2]) : 0;

    final endDateTime = DateTime(
      2026,
      1,
      1,
      hour,
      minute,
      second,
    ).add(Duration(minutes: durationMinutes));

    final formatted =
        '${endDateTime.hour}:${endDateTime.minute.toString().padLeft(2, '0')}';

    return _formatTime(formatted);
  }

  Future<void> _cancelAppointment(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancelar cita'),
          content: const Text('¿Está seguro de que desea cancelar esta cita?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sí, cancelar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await ref.read(updateAppointmentStatusUsecaseProvider)(
        appointmentId: appointment.id,
        status: 'cancelled',
      );

      await ref.read(publicCalendarNotifierProvider.notifier).refresh();

      if (!context.mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cita fue cancelada correctamente.')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cancelar la cita.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCancel =
        appointment.status == 'accepted' || appointment.status == 'requested';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Detalles de la cita',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            _DetailRow(
              icon: Icons.medical_services_outlined,
              label: 'Doctor',
              value: appointment.doctorName,
            ),

            _DetailRow(
              icon: Icons.person_outline,
              label: 'Paciente',
              value: appointment.patientName,
            ),

            _DetailRow(
              icon: Icons.local_hospital_outlined,
              label: 'Clínica',
              value: appointment.clinicName,
            ),

            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Fecha',
              value: _formatDate(appointment.date),
            ),

            _DetailRow(
              icon: Icons.schedule,
              label: 'Horario',
              value:
                  '${_formatTime(appointment.startTime)} - '
                  '${_calculateEndTime(appointment.startTime, appointment.appointmentDuration)}',
            ),

            _DetailRow(
              icon: Icons.timer_outlined,
              label: 'Duración',
              value: '${appointment.appointmentDuration} minutos',
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.info_outline, size: 22),

                const SizedBox(width: 12),

                const Expanded(
                  flex: 2,
                  child: Text(
                    'Estado',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _statusColor(),
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(_statusLabel()),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (canCancel) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelAppointment(context, ref),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar cita'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size.fromHeight(44),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),

          const SizedBox(width: 12),

          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}
