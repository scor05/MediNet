import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/widgets/error_view.dart';
import 'package:frontend/features/calendar/presentation/providers/create_appointment_form_provider.dart';
import 'package:frontend/features/calendar/presentation/widgets/create_appointment/appointment_date_display.dart';
import 'package:frontend/features/calendar/presentation/widgets/create_appointment/dialog_handle.dart';
import 'package:frontend/features/calendar/presentation/widgets/create_appointment/schedule_dropdown.dart';
import 'package:frontend/features/calendar/presentation/widgets/create_appointment/time_slot_dropdown.dart';

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
  final _patientCtrl = TextEditingController();

  @override
  void dispose() {
    _patientCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final created = await ref
        .read(createAppointmentFormProvider(widget.weekStart).notifier)
        .submit(patientName: _patientCtrl.text);

    if (!mounted || created == null) return;

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
            const DialogHandle(),
            const SizedBox(height: 16),
            Text('Nueva cita', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),

            if (formState.loadingSchedules)
              const Center(child: CircularProgressIndicator())
            else if (formState.error != null && formState.schedules.isEmpty)
              ErrorView(
                message: formState.error!,
                onRetry: formNotifier.loadSchedules,
              )
            else if (formState.schedules.isEmpty)
              const Text(
                'No tienes horarios activos. Crea uno primero.',
                style: TextStyle(color: Colors.red),
              )
            else ...[
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
              const SizedBox(height: 10),

              TextFormField(
                controller: _patientCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del paciente',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Requerido' : null,
                onChanged: (_) => formNotifier.clearError(),
              ),

              if (formState.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  formState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (formState.saving || formState.schedules.isEmpty)
                    ? null
                    : _submit,
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
