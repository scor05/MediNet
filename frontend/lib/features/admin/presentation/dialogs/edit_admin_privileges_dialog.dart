import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/admin/presentation/providers/client_users_provider.dart';
import 'package:frontend/features/client/domain/entities/client_user.dart';
import 'package:frontend/theme/app_theme.dart';

class EditAdminPrivilegesDialog extends ConsumerStatefulWidget {
  final int clientId;
  final ClientUser user;
  final bool currentIsAdmin;

  const EditAdminPrivilegesDialog({
    super.key,
    required this.clientId,
    required this.user,
    required this.currentIsAdmin,
  });

  @override
  ConsumerState<EditAdminPrivilegesDialog> createState() =>
      _EditAdminPrivilegesDialogState();
}

class _EditAdminPrivilegesDialogState
    extends ConsumerState<EditAdminPrivilegesDialog> {
  late bool _selectedIsAdmin;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedIsAdmin = widget.currentIsAdmin;
  }

  Future<void> _submit() async {
    setState(() => _saving = true);

    try {
      await ref
          .read(clientUsersNotifierProvider(widget.clientId).notifier)
          .editUser(
            userId: widget.user.user.id,
            role: widget.user.role,
            isAdmin: _selectedIsAdmin,
            isActiveInClient: widget.user.isActiveInClient,
          );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permisos actualizados correctamente')),
      );
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('No se pudieron actualizar los permisos.');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar permisos'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppTheme.accent.withValues(alpha: 0.14),
                child: Text(
                  widget.user.user.name.isNotEmpty
                      ? widget.user.user.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              title: Text(
                widget.user.user.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(widget.user.user.email),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<bool>(
              initialValue: _selectedIsAdmin,
              decoration: const InputDecoration(
                labelText: 'Permisos administrativos',
              ),
              items: const [
                DropdownMenuItem(value: true, child: Text('Administrador')),
                DropdownMenuItem(value: false, child: Text('Ninguno')),
              ],
              onChanged: _saving
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() => _selectedIsAdmin = value);
                    },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
