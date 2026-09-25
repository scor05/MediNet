import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/admin/domain/entities/specialty.dart';
import 'package:frontend/features/admin/presentation/providers/doctor_specialties_provider.dart';
import 'package:frontend/theme/app_theme.dart';

class DoctorSpecialtiesSelector extends ConsumerWidget {
  final int doctorId;

  const DoctorSpecialtiesSelector({super.key, required this.doctorId});

  Future<void> _showAddDialog(
    BuildContext context,
    WidgetRef ref,
    DoctorSpecialtiesState state,
  ) async {
    final assignedIds = state.assignedSpecialties
        .map((item) => item.specialtyId)
        .toSet();

    final available = state.availableSpecialties
        .where((specialty) => !assignedIds.contains(specialty.id))
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay más especialidades disponibles para agregar.'),
        ),
      );

      return;
    }

    final selected = await showDialog<Specialty>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Agregar especialidad'),
          content: SizedBox(
            width: 400,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: available.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final specialty = available[index];

                return ListTile(
                  title: Text(specialty.name),
                  trailing: const Icon(Icons.add),
                  onTap: () {
                    Navigator.pop(dialogContext, specialty);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (selected == null) return;

    await ref
        .read(doctorSpecialtiesProvider(doctorId).notifier)
        .addSpecialty(selected.id);
  }

  Future<void> _showCreateDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Crear especialidad'),
          content: SizedBox(
            width: 350,
            child: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Nombre de la especialidad',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre de la especialidad.';
                  }
                  return null;
                },
                onFieldSubmitted: (value) {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.pop(dialogContext, value.trim());
                  }
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(dialogContext, controller.text.trim());
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    if (name == null || name.isEmpty) return;

    final created = await ref
        .read(doctorSpecialtiesProvider(doctorId).notifier)
        .createSpecialty(name);

    if (created != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Especialidad "${created.name}" creada exitosamente.'),
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int specialtyId,
    String specialtyName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar especialidad'),
          content: Text('¿Deseas desvincular "$specialtyName" de este doctor?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref
        .read(doctorSpecialtiesProvider(doctorId).notifier)
        .removeSpecialty(specialtyId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(doctorSpecialtiesProvider(doctorId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Especialidades',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              tooltip: 'Agregar especialidad',
              onPressed: state.loading || state.saving
                  ? null
                  : () => _showAddDialog(context, ref, state),
              icon: const Icon(Icons.add),
            ),
          ],
        ),

        if (state.loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state.assignedSpecialties.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Este doctor no tiene especialidades asignadas.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.assignedSpecialties.map((item) {
              return Chip(
                label: Text(item.name),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: state.saving
                    ? null
                    : () => _confirmDelete(
                        context,
                        ref,
                        item.specialtyId,
                        item.name,
                      ),
              );
            }).toList(),
          ),

        if (state.error != null) ...[
          const SizedBox(height: 8),
          Text(
            state.error!,
            style: const TextStyle(color: AppColors.error, fontSize: 13),
          ),
        ],

        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: state.loading || state.saving
              ? null
              : () => _showCreateDialog(context, ref),
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: const Text('Crear especialidad'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondary,
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
      ],
    );
  }
}
