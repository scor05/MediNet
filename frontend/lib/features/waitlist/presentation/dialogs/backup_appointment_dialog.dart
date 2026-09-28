import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/core/utils/time_format.dart';
import 'package:frontend/features/calendar/domain/entities/public_slot.dart';
import 'package:frontend/features/calendar/domain/providers/public_calendar_domain_providers.dart';
import 'package:frontend/features/waitlist/domain/providers/waitlist_domain_providers.dart';
import 'package:frontend/features/waitlist/presentation/providers/waitlist_provider.dart';

class BackupAppointmentDialog extends ConsumerStatefulWidget {
  final int waitlistId;
  final int doctorId;
  final String doctorName;
  final int clinicId;
  final String clinicName;
  final DateTime targetDate;
  final String targetStartTime;

  const BackupAppointmentDialog({
    super.key,
    required this.waitlistId,
    required this.doctorId,
    required this.doctorName,
    required this.clinicId,
    required this.clinicName,
    required this.targetDate,
    required this.targetStartTime,
  });

  @override
  ConsumerState<BackupAppointmentDialog> createState() =>
      _BackupAppointmentDialogState();
}

class _BackupAppointmentDialogState
    extends ConsumerState<BackupAppointmentDialog> {
  late DateTime _date;
  List<PublicSlot> _slots = [];
  PublicSlot? _selectedSlot;
  bool _loading = true;
  bool _saving = false;
  bool _showingCloseWarning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _date = widget.targetDate.isBefore(today) ? today : widget.targetDate;
    Future.microtask(_loadSlots);
  }

  Future<void> _loadSlots() async {
    setState(() {
      _loading = true;
      _selectedSlot = null;
      _error = null;
    });
    try {
      final slots = await ref
          .read(getPublicSlotsUsecaseProvider)
          .call(
            doctorId: widget.doctorId,
            clinicId: widget.clinicId,
            date: _date,
          );
      if (!mounted) return;
      setState(() {
        _slots = slots.where((slot) {
          if (slot.isOccupied) return false;
          return !_sameDay(_date, widget.targetDate) ||
              formatTime24(slot.startTime) !=
              formatTime24(widget.targetStartTime);
        }).toList();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _slots = [];
        _error = error is ApiException
            ? error.message
            : 'No se pudieron cargar los horarios disponibles.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(today) ? today : _date,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
    await _loadSlots();
  }

  Future<void> _save() async {
    final slot = _selectedSlot;
    if (slot == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(createBackupAppointmentUsecaseProvider)
          .call(
            waitlistId: widget.waitlistId,
            scheduleId: slot.scheduleId,
            date: _date,
            startTime: slot.startTime,
          );
      ref.invalidate(patientWaitlistNotifierProvider);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _error = error is ApiException
            ? error.message
            : 'No se pudo crear la cita de respaldo.',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmSkip() async {
    if (_showingCloseWarning || _saving) return;
    _showingCloseWarning = true;
    final leave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (warningContext) => AlertDialog(
        title: const Text('Continuar sin cita de respaldo'),
        content: const Text(
          'Si cierras este formulario, no tendrás otra oportunidad para crear '
          'una cita de respaldo para este registro de espera.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(warningContext).pop(false),
            child: const Text('Volver y seleccionar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(warningContext).pop(true),
            child: const Text('Continuar sin respaldo'),
          ),
        ],
      ),
    );
    _showingCloseWarning = false;
    if (leave == true && mounted) {
      try {
        setState(() => _saving = true);
        await ref.read(declineBackupAppointmentUsecaseProvider)(
          widget.waitlistId,
        );
        if (!mounted) return;
        Navigator.of(context).pop(false);
      } catch (error) {
        if (!mounted) return;
        setState(() {
          _saving = false;
          _error = error is ApiException
              ? error.message
              : 'No se pudo guardar tu decisión. Intenta nuevamente.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmSkip();
      },
      child: AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 18, 12, 0),
        title: Row(
          children: [
            const Expanded(child: Text('Cita de respaldo')),
            IconButton(
              tooltip: 'Cerrar',
              onPressed: _saving ? null : _confirmSkip,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Debido a que el Dr. ${widget.doctorName} está ocupado en ese horario y clínica, \npuedes escoger una cita de respaldo para asegurar tu cupo\n en caso de que no se libere la lista de espera.',
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _saving ? null : _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      suffixIcon: Icon(Icons.calendar_month_outlined),
                    ),
                    child: Text(_formatDate(_date)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hora',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_slots.isEmpty)
                  const Text(
                    'No hay horarios libres para esta fecha.',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _slots.map((slot) {
                      final isSelected = identical(slot, _selectedSlot);

                      return ChoiceChip(
                        label: Text(
                          '${formatTime24(slot.startTime)} - '
                          '${formatTime24(slot.endTime)}',
                        ),
                        selected: isSelected,
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: Colors.blue.shade700,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.blue.shade800
                              : Colors.grey.shade400,
                        ),
                        onSelected: _saving
                            ? null
                            : (_) => setState(() => _selectedSlot = slot),
                      );
                    }).toList(),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _confirmSkip,
            child: const Text('No gracias'),
          ),
          FilledButton(
            onPressed: _saving || _selectedSlot == null ? null : _save,
            child: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Solicitar respaldo'),
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';
}
