import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';
import 'package:frontend/features/calendar/presentation/providers/secretary_pending_appointments_provider.dart';
import 'package:frontend/theme/app_theme.dart';

class SecretaryPendingAppointmentsScreen extends ConsumerWidget {
  const SecretaryPendingAppointmentsScreen({super.key});

  String _fmtDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
                  itemBuilder: (context, index) => _PendingAppointmentCard(
                    appointment: appointments[index],
                    dateLabel: _fmtDate(appointments[index].date),
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

  const _PendingAppointmentCard({
    required this.appointment,
    required this.dateLabel,
  });

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
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Solicitada',
                    style: TextStyle(
                      color: Colors.orange.shade900,
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
          ],
        ),
      ),
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
