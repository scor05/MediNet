import 'package:flutter/material.dart';
import 'package:frontend/features/appointment/domain/entities/appointment.dart';

Future<void> showBlockadeDetailSheet({
  required BuildContext context,
  required Appointment blockade,
  required Future<void> Function() onDelete,
}) {
  assert(blockade.isBlockade);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) =>
        _BlockadeDetailContent(blockade: blockade, onDelete: onDelete),
  );
}

class _BlockadeDetailContent extends StatefulWidget {
  final Appointment blockade;
  final Future<void> Function() onDelete;

  const _BlockadeDetailContent({
    required this.blockade,
    required this.onDelete,
  });

  @override
  State<_BlockadeDetailContent> createState() => _BlockadeDetailContentState();
}

class _BlockadeDetailContentState extends State<_BlockadeDetailContent> {
  bool _deleting = false;

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar bloqueo'),
        content: const Text(
          '¿Deseas eliminar este bloqueo de horario? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _deleting = true);
    try {
      await widget.onDelete();
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Bloqueo eliminado')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _deleting = false);
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final blockade = widget.blockade;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
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
              'Detalles del bloqueo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _DetailRow(
              icon: Icons.medical_services_outlined,
              label: 'Doctor',
              value: blockade.doctorName,
            ),
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Clínica',
              value: blockade.clinicName,
            ),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Fecha',
              value: _formatDate(blockade.date),
            ),
            _DetailRow(
              icon: Icons.schedule_outlined,
              label: 'Hora inicial',
              value: _trimTime(blockade.startTime),
            ),
            _DetailRow(
              icon: Icons.schedule,
              label: 'Hora final',
              value: _endTime(blockade),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const ValueKey('blockade-delete-action'),
                onPressed: _deleting ? null : _delete,
                icon: _deleting
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline),
                label: const Text('Eliminar bloqueo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade700),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _deleting ? null : () => Navigator.of(context).pop(),
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

String _trimTime(String value) => value.substring(0, 5);

String _endTime(Appointment blockade) {
  final parts = blockade.startTime.split(':');
  final endMinutes =
      int.parse(parts[0]) * 60 +
      int.parse(parts[1]) +
      blockade.appointmentDuration;
  final normalized = endMinutes % (24 * 60);
  return '${(normalized ~/ 60).toString().padLeft(2, '0')}:'
      '${(normalized % 60).toString().padLeft(2, '0')}';
}
