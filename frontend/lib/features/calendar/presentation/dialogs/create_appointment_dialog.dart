import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/calendar/presentation/providers/create_appointment_form_provider.dart';
import 'package:frontend/features/calendar/presentation/widgets/create_appointment/appointment_date_display.dart';
import 'package:frontend/features/calendar/presentation/widgets/create_appointment/dialog_handle.dart';
import 'package:frontend/features/calendar/presentation/widgets/create_appointment/schedule_dropdown.dart';
import 'package:frontend/features/calendar/presentation/widgets/create_appointment/time_slot_dropdown.dart';
import 'package:frontend/features/clinic/domain/entities/clinic_search_result.dart';
import 'package:frontend/features/search/presentation/widgets/search_input_field.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';
import 'package:frontend/features/user/domain/entities/user.dart';

class CreateAppointmentDialog extends ConsumerStatefulWidget {
  final DateTime weekStart;

  const CreateAppointmentDialog({super.key, required this.weekStart});

  @override
  ConsumerState<CreateAppointmentDialog> createState() =>
      _CreateAppointmentDialogState();
}

class _CreateAppointmentDialogState
    extends ConsumerState<CreateAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();

  final _doctorCtrl = TextEditingController();
  final _clinicCtrl = TextEditingController();
  final _patientCtrl = TextEditingController();

  @override
  void dispose() {
    _doctorCtrl.dispose();
    _clinicCtrl.dispose();
    _patientCtrl.dispose();

    super.dispose();
  }

  Future<void> _selectDoctor(DoctorSearchResult doctor) async {
    _doctorCtrl.value = TextEditingValue(
      text: doctor.name,
      selection: TextSelection.collapsed(offset: doctor.name.length),
    );

    _clinicCtrl.clear();

    await ref
        .read(createAppointmentFormProvider(widget.weekStart).notifier)
        .selectDoctor(doctor);
  }

  void _selectClinic(ClinicSearchResult clinic) {
    _clinicCtrl.value = TextEditingValue(
      text: clinic.name,
      selection: TextSelection.collapsed(offset: clinic.name.length),
    );

    ref
        .read(createAppointmentFormProvider(widget.weekStart).notifier)
        .selectClinic(clinic);
  }

  void _selectPatient(User patient) {
    _patientCtrl.value = TextEditingValue(
      text: patient.name,
      selection: TextSelection.collapsed(offset: patient.name.length),
    );

    ref
        .read(createAppointmentFormProvider(widget.weekStart).notifier)
        .selectPatient(patient);
  }

  void _clearDoctor() {
    _doctorCtrl.clear();
    _clinicCtrl.clear();

    final notifier = ref.read(
      createAppointmentFormProvider(widget.weekStart).notifier,
    );

    notifier.clearDoctor();
    notifier.showDoctorSuggestions();
  }

  void _clearClinic() {
    _clinicCtrl.clear();

    final notifier = ref.read(
      createAppointmentFormProvider(widget.weekStart).notifier,
    );

    notifier.clearClinic();
    notifier.showClinicSuggestions();
  }

  void _clearPatient() {
    _patientCtrl.clear();

    final notifier = ref.read(
      createAppointmentFormProvider(widget.weekStart).notifier,
    );

    notifier.clearPatient();
    notifier.showPatientSuggestions();
  }

  void _onDoctorChanged(String query) {
    _clinicCtrl.clear();

    ref
        .read(createAppointmentFormProvider(widget.weekStart).notifier)
        .onDoctorQueryChanged(query);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final created = await ref
        .read(createAppointmentFormProvider(widget.weekStart).notifier)
        .submit(patientName: _patientCtrl.text);

    if (!mounted) return;

    if (created == null) {
      final message = ref
          .read(createAppointmentFormProvider(widget.weekStart))
          .error;

      if (message != null) {
        final messenger = ScaffoldMessenger.of(context);

        messenger.hideCurrentSnackBar();

        messenger.showSnackBar(SnackBar(content: Text(message)));
      }

      return;
    }

    Navigator.of(context).pop(created);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cita agendada exitosamente')));
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(
      createAppointmentFormProvider(widget.weekStart),
    );

    final formNotifier = ref.read(
      createAppointmentFormProvider(widget.weekStart).notifier,
    );

    final canSubmit =
        !formState.saving &&
        formState.selectedDoctor != null &&
        formState.selectedClinic != null &&
        formState.selectedSchedule != null &&
        formState.selectedDate != null &&
        formState.selectedTime != null;

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
            const DialogHandle(),

            const SizedBox(height: 16),

            Text('Nueva cita', style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 16),

            SearchInputField<DoctorSearchResult>(
              controller: _doctorCtrl,
              label: 'Doctor',
              hintText: 'Nombre o especialidad del doctor',
              loading: formState.loadingDoctors,
              selectedItem: formState.selectedDoctor,
              results: formState.doctorResults,
              titleBuilder: (doctor) => doctor.name,
              subtitleBuilder: (doctor) => doctor.specialty,
              onChanged: _onDoctorChanged,
              onSelected: _selectDoctor,
              onClear: _clearDoctor,
              onEmptyFocus: formNotifier.showDoctorSuggestions,
            ),

            if (formState.selectedDoctor != null) ...[
              const SizedBox(height: 10),

              SearchInputField<ClinicSearchResult>(
                controller: _clinicCtrl,
                label: 'Clínica',
                hintText: 'Nombre de la clínica',
                loading: formState.loadingClinics,
                selectedItem: formState.selectedClinic,
                results: formState.clinicResults,
                titleBuilder: (clinic) => clinic.name,
                subtitleBuilder: (clinic) => clinic.address,
                onChanged: formNotifier.onClinicQueryChanged,
                onSelected: _selectClinic,
                onClear: _clearClinic,
                onEmptyFocus: formNotifier.showClinicSuggestions,
              ),
            ],

            if (formState.loadingSchedules) ...[
              const SizedBox(height: 16),

              const Center(child: CircularProgressIndicator()),
            ],

            if (formState.selectedDoctor != null &&
                !formState.loadingSchedules &&
                formState.selectedClinic == null) ...[
              const SizedBox(height: 10),

              const Text(
                'Selecciona una clínica para continuar.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],

            if (formState.selectedClinic != null &&
                !formState.loadingSchedules &&
                formState.schedules.isEmpty) ...[
              const SizedBox(height: 10),

              const Text(
                'Este doctor no tiene horarios disponibles en esta clínica.',
                style: TextStyle(color: Colors.red),
              ),
            ],

            if (formState.selectedClinic != null &&
                formState.schedules.isNotEmpty) ...[
              const SizedBox(height: 16),

              ScheduleDropdown(
                schedules: formState.schedules,
                selectedSchedule: formState.selectedSchedule,
                onChanged: formNotifier.selectSchedule,
              ),

              const SizedBox(height: 10),

              if (formState.selectedDate != null &&
                  formState.selectedSchedule != null)
                AppointmentDateDisplay(
                  selectedDate: formState.selectedDate!,
                  selectedSchedule: formState.selectedSchedule!,
                ),

              const SizedBox(height: 10),

              TimeSlotDropdown(
                selectedTime: formState.selectedTime,
                timeSlots: formState.timeSlots,
                onChanged: formNotifier.selectTime,
              ),

              const SizedBox(height: 16),

              SearchInputField<User>(
                controller: _patientCtrl,
                label: 'Paciente',
                hintText: 'Nombre del paciente',
                loading: formState.loadingPatients,
                selectedItem: formState.selectedPatient,
                results: formState.patientResults,
                titleBuilder: (patient) => patient.name,
                subtitleBuilder: (patient) => patient.email,
                onChanged: formNotifier.onPatientQueryChanged,
                onSelected: _selectPatient,
                onClear: _clearPatient,
                onEmptyFocus: formNotifier.showPatientSuggestions,
              ),
            ],

            if (formState.error != null) ...[
              const SizedBox(height: 12),

              Text(formState.error!, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canSubmit ? _submit : null,
                child: formState.saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Agendar cita'),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
