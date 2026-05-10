import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/providers/secretary_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/providers/secretary_pending_appointments_provider.dart';
import 'package:frontend/theme/app_theme.dart';

class SecretaryPendingAppointmentsScreen extends ConsumerWidget {
  const SecretaryPendingAppointmentsScreen({super.key});

  String _fmtDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _updateStatus({
    required BuildContext context,
    required WidgetRef ref,
    required Appointment appointment,
    required String status,
  }) async {
    try {
      await ref
          .read(secretaryPendingAppointmentsNotifierProvider.notifier)
          .updateStatus(appointmentId: appointment.id, status: status);
      ref.read(secretaryCalendarNotifierProvider.notifier).refresh();

      if (!context.mounted) return;

      final message = status == 'accepted'
          ? 'Cita aceptada correctamente.'
          : 'Cita rechazada correctamente.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!context.mounted) return;

      final message = e is ApiException ? e.message : 'Error inesperado.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(
      secretaryPendingAppointmentsNotifierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas pendientes'),
        automaticallyImplyLeading: false,
      ),
      body: pendingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e is ApiException ? e.message : 'Error inesperado.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: ref
                    .read(secretaryPendingAppointmentsNotifierProvider.notifier)
                    .refresh,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (appointments) => RefreshIndicator(
          onRefresh: ref
              .read(secretaryPendingAppointmentsNotifierProvider.notifier)
              .refresh,
          child: appointments.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 220),
                    Center(
                      child: Text(
                        'No hay citas pendientes.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, index) => _PendingAppointmentCard(
                    appointment: appointments[index],
                    dateLabel: _fmtDate(appointments[index].date),
                    onAccept: () => _updateStatus(
                      context: context,
                      ref: ref,
                      appointment: appointments[index],
                      status: 'accepted',
                    ),
                    onReject: () => _updateStatus(
                      context: context,
                      ref: ref,
                      appointment: appointments[index],
                      status: 'rejected',
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _PendingAppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String dateLabel;
  final Future<void> Function() onAccept;
  final Future<void> Function() onReject;

  const _PendingAppointmentCard({
    required this.appointment,
    required this.dateLabel,
    required this.onAccept,
    required this.onReject,
  });

  String get _statusLabel {
    return switch (appointment.status) {
      'accepted' => 'Aceptada',
      'rejected' => 'Rechazada',
      'cancelled' => 'Cancelada',
      'rescheduled' => 'Reprogramada',
      'requested' => 'Solicitada',
      _ => appointment.status,
    };
  }

  Color get _statusBackground {
    return switch (appointment.status) {
      'accepted' => Colors.green.shade100,
      'rejected' => Colors.red.shade100,
      'cancelled' => Colors.red.shade100,
      'rescheduled' => Colors.blue.shade100,
      _ => Colors.orange.shade100,
    };
  }

  Color get _statusTextColor {
    return switch (appointment.status) {
      'accepted' => Colors.green.shade900,
      'rejected' => Colors.red.shade900,
      'cancelled' => Colors.red.shade900,
      'rescheduled' => Colors.blue.shade900,
      _ => Colors.orange.shade900,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    appointment.patientName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      color: _statusTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AppointmentDetailRow(
              icon: Icons.medical_services_outlined,
              label: appointment.doctorName,
            ),
            const SizedBox(height: 8),
            _AppointmentDetailRow(
              icon: Icons.calendar_today_outlined,
              label: '$dateLabel - ${appointment.startTime}',
            ),
            const SizedBox(height: 8),
            _AppointmentDetailRow(
              icon: Icons.local_hospital_outlined,
              label: appointment.clinicName,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AppointmentActionButton(label: 'Aceptar', onPressed: onAccept),
                const SizedBox(width: 14),
                _AppointmentActionButton(
                  label: 'Rechazar',
                  onPressed: onReject,
                  hoverColor: AppTheme.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentActionButton extends StatelessWidget {
  final String label;
  final Future<void> Function() onPressed;
  final Color? hoverColor;

  const _AppointmentActionButton({
    required this.label,
    required this.onPressed,
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.hovered) && hoverColor != null) {
            return hoverColor!;
          }

          if (states.contains(WidgetState.hovered)) {
            return AppTheme.primary;
          }

          return AppTheme.secondary;
        }),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        minimumSize: WidgetStateProperty.all(const Size(0, 36)),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () async {
        await onPressed();
      },
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w400)),
    );
  }
}

class _AppointmentDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AppointmentDetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
