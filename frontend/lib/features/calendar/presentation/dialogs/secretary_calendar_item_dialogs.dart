import 'package:flutter/material.dart';
import 'package:frontend/features/calendar/presentation/models/secretary_calendar_item.dart';

Future<SecretaryCalendarItem?> showSecretaryCalendarItemChooser({
  required BuildContext context,
  required List<SecretaryCalendarItem> items,
}) {
  return showModalBottomSheet<SecretaryCalendarItem>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 8, 10),
              child: Text(
                'Elementos en este horario',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...items.map(
              (item) => ListTile(
                leading: Icon(_iconFor(item.type)),
                title: Text(
                  item.fullLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(item.timeRange),
                onTap: () => Navigator.of(sheetContext).pop(item),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showSecretaryBackgroundItemDetails({
  required BuildContext context,
  required SecretaryCalendarItem item,
  Future<void> Function()? onDeleteBlockade,
  Future<void> Function()? onEditSchedule,
  Future<void> Function()? onDeleteSchedule,
}) {
  assert(item.type != SecretaryCalendarItemType.appointment);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => _BackgroundItemDetails(
      item: item,
      onDeleteBlockade: onDeleteBlockade,
      onEditSchedule: onEditSchedule,
      onDeleteSchedule: onDeleteSchedule,
    ),
  );
}

class _BackgroundItemDetails extends StatefulWidget {
  final SecretaryCalendarItem item;
  final Future<void> Function()? onDeleteBlockade;
  final Future<void> Function()? onEditSchedule;
  final Future<void> Function()? onDeleteSchedule;

  const _BackgroundItemDetails({
    required this.item,
    required this.onDeleteBlockade,
    required this.onEditSchedule,
    required this.onDeleteSchedule,
  });

  @override
  State<_BackgroundItemDetails> createState() => _BackgroundItemDetailsState();
}

class _BackgroundItemDetailsState extends State<_BackgroundItemDetails> {
  bool _deleting = false;

  Future<void> _delete({required bool isSchedule}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isSchedule ? 'Eliminar horario' : 'Eliminar bloqueo'),
        content: Text(
          isSchedule
              ? '¿Deseas eliminar este horario? Esta acción dejará de mostrarlo en el calendario.'
              : '¿Deseas eliminar este bloqueo de horario?',
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
      if (isSchedule) {
        await widget.onDeleteSchedule?.call();
      } else {
        await widget.onDeleteBlockade?.call();
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(isSchedule ? 'Horario eliminado' : 'Bloqueo eliminado'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _deleting = false);
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isBlockade = item.type == SecretaryCalendarItemType.blockade;
    final schedule = item.schedule;

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
            Text(
              isBlockade ? 'Detalles del bloqueo' : 'Detalles del horario',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _DetailRow(
              icon: Icons.medical_services_outlined,
              label: 'Doctor',
              value: item.doctorName,
            ),
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Clínica',
              value: item.clinicName,
            ),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: isBlockade ? 'Fecha' : 'Día',
              value: isBlockade
                  ? _formatDate(item.date)
                  : _weekday(item.date.weekday),
            ),
            _DetailRow(
              icon: Icons.schedule,
              label: 'Horario',
              value: item.timeRange,
            ),
            if (schedule != null)
              _DetailRow(
                icon: Icons.timer_outlined,
                label: 'Duración de cita',
                value: '${schedule.duration} minutos',
              ),
            const SizedBox(height: 20),
            if (isBlockade && widget.onDeleteBlockade != null) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _deleting
                      ? null
                      : () => _delete(isSchedule: false),
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
            ],
            if (!isBlockade && widget.onEditSchedule != null) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await widget.onEditSchedule?.call();
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar horario'),
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (!isBlockade && widget.onDeleteSchedule != null) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _deleting ? null : () => _delete(isSchedule: true),
                  icon: _deleting
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  label: const Text('Eliminar horario'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade700),
                    shape: const StadiumBorder(),
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
      padding: const EdgeInsets.only(bottom: 14),
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

IconData _iconFor(SecretaryCalendarItemType type) => switch (type) {
  SecretaryCalendarItemType.appointment => Icons.event_available_outlined,
  SecretaryCalendarItemType.blockade => Icons.block_outlined,
  SecretaryCalendarItemType.schedule => Icons.schedule_outlined,
};

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

String _weekday(int weekday) => const [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
][weekday - 1];
