import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/waitlist/domain/providers/waitlist_domain_providers.dart';

/// Diálogo de confirmación para unirse a la lista de espera.
/// Retorna `true` si el registro fue exitoso.
class JoinWaitlistDialog extends ConsumerStatefulWidget {
  final int targetAppointmentId;
  final int fallbackAppointmentId;
  final String doctorName;
  final String clinicName;
  final String date;
  final String startTime;

  const JoinWaitlistDialog({
    super.key,
    required this.targetAppointmentId,
    required this.fallbackAppointmentId,
    required this.doctorName,
    required this.clinicName,
    required this.date,
    required this.startTime,
  });

  @override
  ConsumerState<JoinWaitlistDialog> createState() => _JoinWaitlistDialogState();
}

class _JoinWaitlistDialogState extends ConsumerState<JoinWaitlistDialog> {
  bool _saving = false;
  String? _error;

  Future<void> _joinWaitlist() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(createWaitlistUsecaseProvider).call(
        targetAppointmentId: widget.targetAppointmentId,
        fallbackAppointmentId: widget.fallbackAppointmentId,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException
            ? e.message
            : 'No se pudo registrar en la lista de espera.';
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lista de espera'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'El horario seleccionado no está disponible. '
            '¿Deseas unirte a la lista de espera? '
            'Te notificaremos cuando se libere.',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person_outline, 'Dr. ${widget.doctorName}'),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.local_hospital_outlined, widget.clinicName),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.calendar_today_outlined, widget.date),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.access_time, widget.startTime),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _joinWaitlist,
          child: _saving
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Unirme'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
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
