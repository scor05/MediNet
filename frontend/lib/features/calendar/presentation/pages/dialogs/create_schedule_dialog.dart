import 'package:flutter/material.dart';

import '../../../domain/entities/clinic.dart';
import '../../../data/datasources/clinic_remote_datasource.dart';
import '../../../data/repositories/clinic_repository_impl.dart';
import '../../../domain/usecases/get_clinics.dart';

import '../../../data/datasources/schedule_remote_datasource.dart';
import '../../../data/repositories/schedule_repository_impl.dart';
import '../../../domain/usecases/create_schedule.dart';

class CreateScheduleDialog extends StatefulWidget {
  const CreateScheduleDialog({super.key});

  @override
  State<CreateScheduleDialog> createState() => _CreateScheduleDialogState();
}

class _CreateScheduleDialogState extends State<CreateScheduleDialog> {
  // Inicialización de dependencias
  final _getClinicsUsecase = GetClinics(
    ClinicRepositoryImpl(ClinicRemoteDatasource()),
  );
  final _createScheduleUsecase = CreateSchedule(
    ScheduleRepositoryImpl(ScheduleRemoteDatasource()),
  );

  // Estado
  final _formKey = GlobalKey<FormState>();
  List<Clinic> _clinics = [];
  int? _selectedClinic;
  int _dayOfWeek = 0;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 16, minute: 0);
  final _durationCtrl = TextEditingController(text: '30');
  bool _loadingClinics = true;
  bool _saving = false;

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
    _fetchClinics();
  }

  @override
  void dispose() {
    _durationCtrl.dispose();
    super.dispose();
  }

  // Se obtienen las clínicas registradas
  Future<void> _fetchClinics() async {
    try {
      final clinics = await _getClinicsUsecase();
      setState(() {
        _clinics = clinics;
        if (_clinics.isNotEmpty) _selectedClinic = _clinics.first.id;
      });
    } catch (_) {}
    if (mounted) {
      setState(() => _loadingClinics = false);
    }
  }

  // Función para elegir una hora del día
  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          _startTime = picked;
        else
          _endTime = picked;
      });
    }
  }

  // Formato de hora
  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // Validación de rango de horas
  bool _isValidRange() {
    final startMins = _startTime.hour * 60 + _startTime.minute;
    final endMins = _endTime.hour * 60 + _endTime.minute;
    return endMins > startMins;
  }

  // Envía el horario al backend
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClinic == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona una clínica.')));
      return;
    }
    if (!_isValidRange()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora de inicio debe ser anterior a la de fin.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);

    try {
      await _createScheduleUsecase(
        idClinic: _selectedClinic!,
        dayOfWeek: _dayOfWeek,
        startTime: _fmt(_startTime),
        endTime: _fmt(_endTime),
        duration: int.parse(_durationCtrl.text.trim()),
      );

      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horario creado exitosamente')),
      );
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (msg.startsWith('Exception: ')) msg = msg.substring(11);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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

            // Clínica
            if (_loadingClinics)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<int>(
                value: _selectedClinic,
                decoration: const InputDecoration(labelText: 'Clínica'),
                items: _clinics
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedClinic = v),
                validator: (v) => v == null ? 'Selecciona una clínica' : null,
              ),
            const SizedBox(height: 10),

            // Día de la semana
            DropdownButtonFormField<int>(
              value: _dayOfWeek,
              decoration: const InputDecoration(labelText: 'Día de la semana'),
              items: List.generate(
                7,
                (i) => DropdownMenuItem(value: i, child: Text(_days[i])),
              ),
              onChanged: (v) => setState(() => _dayOfWeek = v!),
            ),
            const SizedBox(height: 10),

            // Horas
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
                      decoration: const InputDecoration(labelText: 'Hora fin'),
                      child: Text(_fmt(_endTime)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Duración
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
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _submit,
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
