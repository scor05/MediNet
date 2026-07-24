import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/calendar/domain/entities/public_slot.dart';
import 'package:frontend/features/calendar/domain/providers/public_calendar_domain_providers.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/features/user/domain/entities/patient_profile.dart';
import 'package:frontend/features/user/domain/entities/user.dart';
import 'package:frontend/features/user/domain/providers/user_domain_providers.dart';

class PublicCreateAppointmentDialog extends ConsumerStatefulWidget {
  final int? initialDoctorId;
  final int? initialClinicId;

  const PublicCreateAppointmentDialog({
    super.key,
    this.initialDoctorId,
    this.initialClinicId,
  });

  @override
  ConsumerState<PublicCreateAppointmentDialog> createState() =>
      _PublicCreateAppointmentDialogState();
}

class _PublicCreateAppointmentDialogState
    extends ConsumerState<PublicCreateAppointmentDialog> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  List<User> _doctors = [];
  List<Clinic> _clinics = [];
  List<PublicSlot> _slots = [];

  int? _selectedDoctorId;
  int? _selectedClinicId;
  DateTime _selectedDate = DateTime.now();
  PublicSlot? _selectedSlot;

  PatientProfile? _patientProfile;
  bool _loadingProfile = false;
  bool _isProfileLoaded = false;
  String? _profileError;

  bool _loadingInitial = true;
  bool _loadingSlots = false;
  bool _saving = false;
  String? _error;
  String? _slotsError;

  @override
  void initState() {
    super.initState();
    _selectedDoctorId = widget.initialDoctorId;
    _selectedClinicId = widget.initialClinicId;
    Future.microtask(_loadInitialData);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _loadingInitial = true;
      _error = null;
    });

    try {
      _loadPatientProfile();

      final doctors = await ref
          .read(getPublicDoctorsUsecaseProvider)
          .call(clinicId: _selectedClinicId);
      final clinics = await ref
          .read(getPublicClinicsUsecaseProvider)
          .call(doctorId: _selectedDoctorId);

      _doctors = doctors;
      _clinics = clinics;
      _selectedDoctorId = _validDoctorId(_selectedDoctorId);
      _selectedClinicId = _validClinicId(_selectedClinicId);

      if (_selectedDoctorId != null && _selectedClinicId != null) {
        await _loadSlots();
      }
    } catch (e) {
      _error = e is ApiException ? e.message : 'Error inesperado.';
    } finally {
      if (mounted) {
        setState(() => _loadingInitial = false);
      }
    }
  }

  Future<void> _loadPatientProfile() async {
    if (_isProfileLoaded) return;

    setState(() {
      _loadingProfile = true;
      _profileError = null;
    });

    try {
      final profile = await ref.read(getPatientProfileUsecaseProvider).call();
      if (!mounted) return;

      setState(() {
        _patientProfile = profile;
        if (!_isProfileLoaded) {
          _nameCtrl.text = profile.name;
          _phoneCtrl.text = profile.phone;
          _emailCtrl.text = profile.email;
          _isProfileLoaded = true;
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _profileError = e is ApiException
              ? e.message
              : 'No se pudo cargar el perfil del paciente.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loadingProfile = false);
      }
    }
  }

  int? _validDoctorId(int? doctorId) {
    if (_doctors.any((doctor) => doctor.id == doctorId)) {
      return doctorId;
    }

    return _doctors.isNotEmpty ? _doctors.first.id : null;
  }

  int? _validClinicId(int? clinicId) {
    if (_clinics.any((clinic) => clinic.id == clinicId)) {
      return clinicId;
    }

    return _clinics.isNotEmpty ? _clinics.first.id : null;
  }

  Future<void> _loadSlots() async {
    final doctorId = _selectedDoctorId;
    final clinicId = _selectedClinicId;

    if (doctorId == null || clinicId == null) {
      setState(() {
        _slots = [];
        _slotsError = null;
        _selectedSlot = null;
      });
      return;
    }

    setState(() {
      _loadingSlots = true;
      _slotsError = null;
      _selectedSlot = null;
    });

    try {
      final slots = await ref
          .read(getPublicSlotsUsecaseProvider)
          .call(doctorId: doctorId, clinicId: clinicId, date: _selectedDate);

      if (mounted) {
        setState(() => _slots = slots);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _slots = [];
          _slotsError = e is ApiException ? e.message : 'Error inesperado.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loadingSlots = false);
      }
    }
  }

  Future<void> _onDoctorChanged(int? doctorId) async {
    setState(() => _selectedDoctorId = doctorId);

    final clinics = await ref
        .read(getPublicClinicsUsecaseProvider)
        .call(doctorId: doctorId);

    if (!mounted) return;

    setState(() {
      _clinics = clinics;
      _selectedClinicId = _validClinicId(_selectedClinicId);
    });

    await _loadSlots();
  }

  Future<void> _onClinicChanged(int? clinicId) async {
    setState(() => _selectedClinicId = clinicId);

    final doctors = await ref
        .read(getPublicDoctorsUsecaseProvider)
        .call(clinicId: clinicId);

    if (!mounted) return;

    setState(() {
      _doctors = doctors;
      _selectedDoctorId = _validDoctorId(_selectedDoctorId);
    });

    await _loadSlots();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked == null) return;

    setState(() => _selectedDate = picked);
    await _loadSlots();
  }

  String _fmtDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _confirmAppointment() async {
    final selectedSlot = _selectedSlot;

    if (selectedSlot == null) {
      setState(() => _error = 'Selecciona un horario disponible.');
      return;
    }

    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Ingresa el nombre del paciente.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final patientId = _patientProfile?.id ??
          (await ref.read(getProfileUsecaseProvider).call()).id;

      await ref
          .read(createPublicAppointmentRequestUsecaseProvider)
          .call(
            scheduleId: selectedSlot.scheduleId,
            patientId: patientId,
            patientName: _nameCtrl.text.trim(),
            date: _selectedDate,
            startTime: selectedSlot.startTime,
          );

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop(selectedSlot);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Solicitud enviada, pendiente de aprobación'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e is ApiException
            ? e.message
            : 'No se pudo enviar la solicitud.';
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
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
      child: _loadingInitial
          ? const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
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
                    'Agendar cita',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  if (_error != null && (_doctors.isEmpty || _clinics.isEmpty))
                    Text(_error!, style: const TextStyle(color: Colors.red))
                  else if (_doctors.isEmpty || _clinics.isEmpty)
                    const Text(
                      'No hay horarios disponibles para agendar.',
                      style: TextStyle(color: Colors.red),
                    )
                  else ...[
                    // Sección Datos del Paciente
                    Text(
                      'Datos del paciente',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),

                    if (_loadingProfile)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_profileError != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _profileError!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: _loadPatientProfile,
                            child: const Text('Reintentar', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del paciente *',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico (solo lectura)',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Sección Detalle de la Cita
                    Text(
                      'Detalles de la cita',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),

                    DropdownButtonFormField<int>(
                      key: ValueKey('doctor-${_selectedDoctorId ?? 0}'),
                      initialValue: _selectedDoctorId,
                      decoration: const InputDecoration(labelText: 'Doctor'),
                      items: _doctors
                          .map(
                            (doctor) => DropdownMenuItem(
                              value: doctor.id,
                              child: Text(doctor.name),
                            ),
                          )
                          .toList(),
                      onChanged: _onDoctorChanged,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      key: ValueKey('clinic-${_selectedClinicId ?? 0}'),
                      initialValue: _selectedClinicId,
                      decoration: const InputDecoration(labelText: 'Clínica'),
                      items: _clinics
                          .map(
                            (clinic) => DropdownMenuItem(
                              value: clinic.id,
                              child: Text(clinic.name),
                            ),
                          )
                          .toList(),
                      onChanged: _onClinicChanged,
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(4),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Fecha'),
                        child: Text(
                          _fmtDate(_selectedDate),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Horarios disponibles',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 10),
                    if (_loadingSlots)
                      const Center(child: CircularProgressIndicator())
                    else if (_slotsError != null)
                      Text(
                        _slotsError!,
                        style: const TextStyle(color: Colors.red),
                      )
                    else if (_slots.isEmpty)
                      const Text(
                        'No hay slots disponibles para esta selección.',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _slots
                            .map(
                              (slot) => ChoiceChip(
                                label: Text(
                                  '${slot.startTime} - ${slot.endTime}',
                                ),
                                selected: _selectedSlot == slot,
                                onSelected: (_) {
                                  setState(() => _selectedSlot = slot);
                                },
                              ),
                            )
                            .toList(),
                      ),
                  ],

                  if (_error != null &&
                      _doctors.isNotEmpty &&
                      _clinics.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: FilledButton(
                      onPressed: (_saving || _selectedSlot == null)
                          ? null
                          : _confirmAppointment,
                      child: _saving
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Confirmar Cita'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: FilledButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
