import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/admin/presentation/providers/client_users_provider.dart';
import 'package:frontend/features/admin/presentation/widgets/add_user/admin_selector.dart';
import 'package:frontend/features/admin/presentation/widgets/add_user/role_dropdown.dart';
import 'package:frontend/features/admin/presentation/widgets/add_user/search_error_message.dart';
import 'package:frontend/features/admin/presentation/widgets/add_user/search_results_list.dart';
import 'package:frontend/features/admin/presentation/widgets/add_user/user_search_field.dart';
import 'package:frontend/features/client/domain/entities/client_user.dart';

class AddUserDialog extends ConsumerStatefulWidget {
  final int clientId;
  final Future<void> Function(int userId, String role, bool isAdmin) onAdd;
  final void Function(String message) onError;

  const AddUserDialog({
    super.key,
    required this.clientId,
    required this.onAdd,
    required this.onError,
  });

  @override
  ConsumerState<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends ConsumerState<AddUserDialog> {
  final TextEditingController _emailCtrl = TextEditingController();

  Timer? _debounce;

  String _selectedRole = 'doctor';
  bool _isAdmin = false;

  ClientUser? _selectedUser;
  List<ClientUser> _searchResults = [];

  bool _isSearching = false;
  bool _saving = false;
  String? _searchError;

  @override
  void dispose() {
    _debounce?.cancel();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_selectedUser != null) {
      setState(() {
        _selectedUser = null;
        _searchResults = [];
        _searchError = null;
      });
    }

    _debounce?.cancel();

    if (value.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _searchError = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchUsers(value.trim());
    });
  }

  Future<void> _searchUsers(String search) async {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = await ref.read(
        availableUsersForClientProvider((
          clientId: widget.clientId,
          search: search,
        )).future,
      );

      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _searchResults = [];
        _isSearching = false;
        _searchError = e is ApiException
            ? e.message
            : 'Error al buscar usuarios.';
      });
    }
  }

  void _selectUser(ClientUser user) {
    _debounce?.cancel();

    setState(() {
      _selectedUser = user;
      _searchResults = [];
      _searchError = null;
      _emailCtrl.text = user.user.email;
    });
  }

  void _onRoleChanged(String? value) {
    if (value == null) return;

    setState(() {
      _selectedRole = value;

      if (value == 'admin') {
        _isAdmin = true;
      }
    });
  }

  Future<void> _submit() async {
    final selectedUser = _selectedUser;

    if (selectedUser == null || _saving) return;

    setState(() => _saving = true);

    try {
      await widget.onAdd(selectedUser.user.id, _selectedRole, _isAdmin);

      if (!mounted) return;

      Navigator.pop(context);
    } on ApiException catch (e) {
      widget.onError(e.message);
    } catch (_) {
      widget.onError('Error al agregar el usuario.');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  double get _resultsPanelHeight {
    const rowHeight = 58.0;
    const maxHeight = 180.0;

    return math.min(_searchResults.length * rowHeight, maxHeight);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar usuario'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserSearchField(
              controller: _emailCtrl,
              isSearching: _isSearching,
              selectedUser: _selectedUser,
              onChanged: _onSearchChanged,
            ),

            const SizedBox(height: 8),

            if (_searchError != null)
              SearchErrorMessage(message: _searchError!),

            if (_searchResults.isNotEmpty && _selectedUser == null)
              SearchResultsList(
                height: _resultsPanelHeight,
                results: _searchResults,
                onSelect: _selectUser,
              ),

            const SizedBox(height: 12),

            RoleDropdown(
              selectedRole: _selectedRole,
              onChanged: _onRoleChanged,
            ),

            const SizedBox(height: 12),

            AdminSelector(
              selectedRole: _selectedRole,
              isAdmin: _isAdmin,
              onAdminChanged: (value) {
                setState(() => _isAdmin = value);
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedUser == null || _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Agregar'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade500,
                  foregroundColor: Colors.white,
                ),
                onPressed: _saving ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
