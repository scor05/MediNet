import 'package:flutter/material.dart';
import 'package:frontend/features/admin/presentation/widgets/add_user/admin_option.dart';

class AdminSelector extends StatelessWidget {
  final String selectedRole;
  final bool isAdmin;
  final ValueChanged<bool> onAdminChanged;

  const AdminSelector({
    super.key,
    required this.selectedRole,
    required this.isAdmin,
    required this.onAdminChanged,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = selectedRole == 'admin';

    return Row(
      children: [
        const Expanded(child: Text('¿Es administrador?')),
        AdminOption(
          label: 'Sí',
          selected: isAdmin,
          disabled: disabled,
          onTap: () => onAdminChanged(true),
        ),
        const SizedBox(width: 8),
        AdminOption(
          label: 'No',
          selected: !isAdmin,
          disabled: disabled,
          onTap: () => onAdminChanged(false),
        ),
      ],
    );
  }
}
