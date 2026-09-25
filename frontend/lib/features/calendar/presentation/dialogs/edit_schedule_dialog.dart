import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/calendar/presentation/providers/doctor_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/providers/secretary_calendar_provider.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/features/clinic/domain/providers/clinic_domain_providers.dart';
import 'package:frontend/features/schedule/domain/entities/schedule.dart';

class EditScheduleDialog extends ConsumerStatefulWidget {
  final Schedule schedule;
  final bool forSecretary;

  const EditScheduleDialog({
    super.key,
    required this.schedule,
    required this.forSecretary,
  });

  @override
  ConsumerState<EditScheduleDialog> createState() => _EditScheduleDialogState();
}

class _EditScheduleDialogState extends ConsumerState<EditScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _durationController;
  List<Clinic> _clinics = [];
  int? _clinicId;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _clinicId = widget.schedule.clinicId;
    _startTime = _parseTime(widget.schedule.startTime);
    _endTime = _parseTime(widget.schedule.endTime);
    _durationController = TextEditingController(
      text: widget.schedule.duration.toString(),
    );
    _loadClinics();
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';

  Future<void> _loadClinics() async {
    try {
      final clinics = await ref.read(getClinicsUsecaseProvider).call(null);
      if (!mounted) return;
      setState(() {
        _clinics = clinics;
        if (!clinics.any((clinic) => clinic.id == _clinicId)) {
          _clinicId = clinics.isEmpty ? null : clinics.first.id;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _error = error is ApiException
            ? error.message
            : 'No se pudieron cargar las clínicas.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickTime(bool start) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: start ? _startTime : _endTime,
    );
    if (selected == null) return;
    setState(() {
      if (start) {
        _startTime = selected;
      } else {
        _endTime = selected;
      }
      _error = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _clinicId == null) return;
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    if (endMinutes <= startMinutes) {
      setState(
        () => _error = 'La hora de inicio debe ser anterior a la de fin.',
      );
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (widget.forSecretary) {
        await ref
            .read(secretaryCalendarNotifierProvider.notifier)
            .updateSchedule(
              id: widget.schedule.id,
              clinicId: _clinicId!,
              startTime: _startTime,
              endTime: _endTime,
              duration: int.parse(_durationController.text.trim()),
            );
      } else {
        await ref
            .read(doctorCalendarNotifierProvider.notifier)
            .updateSchedule(
              id: widget.schedule.id,
              clinicId: _clinicId!,
              startTime: _startTime,
              endTime: _endTime,
              duration: int.parse(_durationController.text.trim()),
            );
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Horario actualizado')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _error = error is ApiException
            ? error.message
            : error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Editar horario',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              DropdownButtonFormField<int>(
                initialValue: _clinicId,
                decoration: const InputDecoration(labelText: 'Clínica'),
                items: _clinics
                    .map(
                      (clinic) => DropdownMenuItem(
                        value: clinic.id,
                        child: Text(clinic.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _clinicId = value),
                validator: (value) =>
                    value == null ? 'Selecciona una clínica' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hora inicio',
                        ),
                        child: Text(_formatTime(_startTime)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hora fin',
                        ),
                        child: Text(_formatTime(_endTime)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duración por cita (minutos)',
                ),
                validator: (value) {
                  final duration = int.tryParse(value?.trim() ?? '');
                  return duration == null || duration < 10
                      ? 'Mínimo 10 min'
                      : null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar cambios'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
