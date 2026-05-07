import 'package:flutter/material.dart';

class RoleDropdown extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String?> onChanged;

  const RoleDropdown({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedRole,
      decoration: const InputDecoration(labelText: 'Rol'),
      items: const [
        DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
        DropdownMenuItem(value: 'secretary', child: Text('Secretaria')),
        DropdownMenuItem(value: 'admin', child: Text('Administrador')),
      ],
      onChanged: onChanged,
    );
  }
}
