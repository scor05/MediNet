import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/calendar/presentation/providers/doctor_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/providers/secretary_calendar_provider.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/features/clinic/domain/providers/clinic_domain_providers.dart';
import 'package:frontend/features/search/presentation/providers/search_form_provider.dart';
import 'package:frontend/features/search/presentation/widgets/search_input_field.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';

class CreateScheduleDialog extends ConsumerStatefulWidget {
  final bool forSecretary;

  const CreateScheduleDialog({super.key, this.forSecretary = false});

  @override
  ConsumerState<CreateScheduleDialog> createState() =>
      _CreateScheduleDialogState();
}

class _CreateScheduleDialogState extends ConsumerState<CreateScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _doctorCtrl = TextEditingController();
  List<Clinic> _clinics = [];
  int? _selectedClinic;
  int _dayOfWeek = 0;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 16, minute: 0);
  final _durationCtrl = TextEditingController();

  bool _loadingClinics = true;
  bool _saving = false;
  String? _error;

  static const _days = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  @override
  void initState() {
    super.initState();
    _durationCtrl.text = '30';
    _fetchClinics();
  }

  @override
  void dispose() {
    _doctorCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  void _selectDoctor(DoctorSearchResult doctor) {
    _doctorCtrl.value = TextEditingValue(
      text: doctor.name,
      selection: TextSelection.collapsed(offset: doctor.name.length),
    );
    ref.read(searchFormNotifierProvider.notifier).selectDoctor(doctor);
    setState(() => _error = null);
  }

  void _clearDoctor() {
    _doctorCtrl.clear();
    final notifier = ref.read(searchFormNotifierProvider.notifier);
    notifier.clearDoctor();
    notifier.showDoctorSuggestions();
    setState(() => _error = null);
  }

  Future<void> _fetchClinics() async {
    setState(() {
      _loadingClinics = true;
      _error = null;
    });

    try {
      final clinics = await ref.read(getClinicsUsecaseProvider).call(null);

      if (!mounted) return;

      setState(() {
        _clinics = clinics;
        if (_clinics.isNotEmpty) _selectedClinic = _clinics.first.id;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _clinics = [];
        _selectedClinic = null;
        _error = e is ApiException ? e.message : 'Ocurrió un error inesperado.';
      });
    } finally {
      if (mounted) setState(() => _loadingClinics = false);
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        _error = null;
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  bool _isValidRange() {
    final startMins = _startTime.hour * 60 + _startTime.minute;
    final endMins = _endTime.hour * 60 + _endTime.minute;
    return endMins > startMins;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedDoctor = ref.read(searchFormNotifierProvider).selectedDoctor;
    if (widget.forSecretary && selectedDoctor == null) {
      setState(() => _error = 'Selecciona un doctor.');
      return;
    }

    if (_selectedClinic == null) {
      setState(() => _error = 'Selecciona una clínica.');
      return;
    }

    if (!_isValidRange()) {
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
            .createSchedule(
              doctorId: selectedDoctor!.id,
              clinicId: _selectedClinic!,
              dayOfWeek: _dayOfWeek,
              startTime: _startTime,
              endTime: _endTime,
              duration: int.parse(_durationCtrl.text.trim()),
            );
      } else {
        await ref
            .read(doctorCalendarNotifierProvider.notifier)
            .createSchedule(
              clinicId: _selectedClinic!,
              dayOfWeek: _dayOfWeek,
              startTime: _startTime,
              endTime: _endTime,
              duration: int.parse(_durationCtrl.text.trim()),
            );
      }

      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horario creado exitosamente')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (e is ApiException) {
          _error = e.message;
        } else {
          String msg = e.toString();
          if (msg.startsWith('Exception: ')) msg = msg.substring(11);
          _error = msg.isEmpty ? 'Ocurrió un error inesperado.' : msg;
        }
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchFormNotifierProvider);
    final searchNotifier = ref.read(searchFormNotifierProvider.notifier);
    final canSubmit =
        !_saving &&
        (!widget.forSecretary || searchState.selectedDoctor != null);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
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
              'Nuevo horario',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            if (widget.forSecretary) ...[
              SearchInputField<DoctorSearchResult>(
                controller: _doctorCtrl,
                label: 'Doctor',
                hintText: 'Nombre o especialidad del doctor',
                loading: searchState.loadingDoctors,
                selectedItem: searchState.selectedDoctor,
                results: searchState.doctorResults,
                titleBuilder: (doctor) => doctor.name,
                subtitleBuilder: (doctor) => doctor.specialty,
                onChanged: searchNotifier.onDoctorQueryChanged,
                onSelected: _selectDoctor,
                onClear: _clearDoctor,
                onEmptyFocus: searchNotifier.showDoctorSuggestions,
              ),
              const SizedBox(height: 10),
            ],

            if (_loadingClinics)
              const Center(child: CircularProgressIndicator())
            else if (_error != null && _clinics.isEmpty)
              Center(
                child: Column(
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _fetchClinics,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            else ...[
              DropdownButtonFormField<int>(
                initialValue: _selectedClinic,
                decoration: const InputDecoration(labelText: 'Clínica'),
                items: _clinics
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedClinic = v;
                  _error = null;
                }),
                validator: (v) => v == null ? 'Selecciona una clínica' : null,
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<int>(
                initialValue: _dayOfWeek,
                decoration: const InputDecoration(
                  labelText: 'Día de la semana',
                ),
                items: List.generate(
                  7,
                  (i) => DropdownMenuItem(value: i, child: Text(_days[i])),
                ),
                onChanged: (v) => setState(() {
                  _dayOfWeek = v!;
                  _error = null;
                }),
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
                        child: Text(_fmt(_startTime)),
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
                        child: Text(_fmt(_endTime)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _durationCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duración por cita (minutos)',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requerido';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 5) return 'Mínimo 5 min';
                  return null;
                },
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],

              if (widget.forSecretary && searchState.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  searchState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canSubmit ? _submit : null,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar horario'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
