import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/waitlist/domain/entities/waitlist.dart';
import 'package:frontend/features/waitlist/presentation/providers/waitlist_provider.dart';
import 'package:frontend/theme/app_theme.dart';

class PatientWaitlistScreen extends ConsumerWidget {
  const PatientWaitlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waitlistAsync = ref.watch(patientWaitlistNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi lista de espera')),
      body: waitlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          final message = error is ApiException
              ? error.message
              : 'No se pudo cargar la lista de espera.';
          return _ErrorView(
            message: message,
            onRetry: ref.read(patientWaitlistNotifierProvider.notifier).refresh,
          );
        },
        data: (waitlists) {
          if (waitlists.isEmpty) {
            return const _EmptyView();
          }

          return RefreshIndicator(
            onRefresh:
                ref.read(patientWaitlistNotifierProvider.notifier).refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: waitlists.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final waitlist = waitlists[index];
                return _WaitlistCard(waitlist: waitlist);
              },
            ),
          );
        },
      ),
    );
  }
}

class _WaitlistCard extends ConsumerWidget {
  final Waitlist waitlist;

  const _WaitlistCard({required this.waitlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusBadge(status: waitlist.status),
                const Spacer(),
                if (waitlist.isActive)
                  TextButton.icon(
                    onPressed: () => _confirmCancel(context, ref),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Cancelar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (waitlist.doctorName != null)
              _InfoRow(
                icon: Icons.person_outline,
                text: 'Dr. ${waitlist.doctorName}',
              ),
            if (waitlist.clinicName != null) ...[
              const SizedBox(height: 4),
              _InfoRow(
                icon: Icons.local_hospital_outlined,
                text: waitlist.clinicName!,
              ),
            ],
            if (waitlist.targetDate != null) ...[
              const SizedBox(height: 4),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                text: waitlist.targetDate!,
              ),
            ],
            if (waitlist.targetStartTime != null) ...[
              const SizedBox(height: 4),
              _InfoRow(
                icon: Icons.access_time,
                text: waitlist.targetStartTime!,
              ),
            ],
            const SizedBox(height: 6),
            Text(
              'Registrado: ${_fmtDateTime(waitlist.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar registro'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar tu registro en la lista de espera?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(patientWaitlistNotifierProvider.notifier)
            .cancelWaitlist(waitlist.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro cancelado exitosamente.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          final message = e is ApiException
              ? e.message
              : 'No se pudo cancelar el registro.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    }
  }

  String _fmtDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'active' => ('En espera', AppColors.secondary),
      'notified' => ('Notificado', AppColors.success),
      'fulfilled' => ('Cumplido', AppColors.success),
      'expired' => ('Expirado', AppColors.textMuted),
      'cancelled' => ('Cancelado', AppColors.error),
      _ => (status, AppColors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty, size: 48, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text(
              'No tienes registros en lista de espera.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
