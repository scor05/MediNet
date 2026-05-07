import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/utils/auth_role_labels.dart';
import 'package:frontend/theme/app_theme.dart';

class DefaultRoleCard extends StatelessWidget {
  final List<String> roles;
  final String? selectedRole;
  final bool loading;
  final ValueChanged<String?> onChanged;

  const DefaultRoleCard({
    super.key,
    required this.roles,
    required this.selectedRole,
    required this.loading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: AppTheme.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: loading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : DropdownButtonFormField<String?>(
                value: selectedRole,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.swap_horiz, color: AppTheme.textSecondary),
                ),
                hint: const Text('Ninguno (mostrar selección)'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Ninguno (mostrar selección)'),
                  ),
                  ...roles.map(
                    (role) => DropdownMenuItem<String?>(
                      value: role,
                      child: Text(AuthRoleLabels.label(role)),
                    ),
                  ),
                ],
                onChanged: onChanged,
              ),
      ),
    );
  }
}
