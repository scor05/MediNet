import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/calendar/domain/entities/public_slot.dart';
import 'package:frontend/features/calendar/presentation/providers/public_calendar_provider.dart';

class PublicCreateAppointmentDialog extends ConsumerStatefulWidget {
  const PublicCreateAppointmentDialog({super.key});

  @override
  ConsumerState<PublicCreateAppointmentDialog> createState() =>
      _PublicCreateAppointmentDialogState();
}

class _PublicCreateAppointmentDialogState
    extends ConsumerState<PublicCreateAppointmentDialog> {
  PublicSlot? _selectedSlot;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(publicCalendarNotifierProvider.notifier).getSlots();
    });
  }

  Future<void> _pickDate(DateTime initialDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) {
      ref.read(publicCalendarNotifierProvider.notifier).setSelectedDate(picked);
      setState(() => _selectedSlot = null);
      await ref.read(publicCalendarNotifierProvider.notifier).getSlots();
    }
  }

  Future<void> _onDoctorChanged(int? doctorId) async {
    ref
        .read(publicCalendarNotifierProvider.notifier)
        .setActiveDoctorId(doctorId);
    setState(() => _selectedSlot = null);
    await ref.read(publicCalendarNotifierProvider.notifier).getSlots();
  }

  Future<void> _onClinicChanged(int? clinicId) async {
    ref
        .read(publicCalendarNotifierProvider.notifier)
        .setActiveClinicId(clinicId);
    setState(() => _selectedSlot = null);
    await ref.read(publicCalendarNotifierProvider.notifier).getSlots();
  }

  String _fmtDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(publicCalendarNotifierProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: calendarAsync.when(
        loading: () => const SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => SizedBox(
          height: 220,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.toString(), style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: ref
                      .read(publicCalendarNotifierProvider.notifier)
                      .refresh,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (state) => SingleChildScrollView(
          child: Builder(
            builder: (context) {
              final selectedDoctorId =
                  state.doctors.any(
                    (doctor) => doctor.id == state.activeDoctorId,
                  )
                  ? state.activeDoctorId
                  : (state.doctors.isNotEmpty ? state.doctors.first.id : null);
              final selectedClinicId =
                  state.clinics.any(
                    (clinic) => clinic.id == state.activeClinicId,
                  )
                  ? state.activeClinicId
                  : (state.clinics.isNotEmpty ? state.clinics.first.id : null);

              return Column(
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

                  if (state.doctors.isEmpty || state.clinics.isEmpty)
                    const Text(
                      'No hay horarios disponibles para agendar.',
                      style: TextStyle(color: Colors.red),
                    )
                  else ...[
                    DropdownButtonFormField<int>(
                      initialValue: selectedDoctorId,
                      decoration: const InputDecoration(labelText: 'Doctor'),
                      items: state.doctors
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
                      initialValue: selectedClinicId,
                      decoration: const InputDecoration(labelText: 'Clínica'),
                      items: state.clinics
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
                      onTap: () =>
                          _pickDate(state.selectedDate ?? DateTime.now()),
                      borderRadius: BorderRadius.circular(4),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Fecha'),
                        child: Text(
                          _fmtDate(state.selectedDate ?? DateTime.now()),
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

                    if (state.loadingSlots)
                      const Center(child: CircularProgressIndicator())
                    else if (state.slotsError != null)
                      Text(
                        state.slotsError!,
                        style: const TextStyle(color: Colors.red),
                      )
                    else if (state.slots.isEmpty)
                      const Text(
                        'No hay slots disponibles para esta selección.',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.slots
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

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(_selectedSlot),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
