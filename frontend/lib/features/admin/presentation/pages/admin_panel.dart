import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/admin/presentation/providers/client_users_provider.dart';
import 'package:frontend/features/auth/presentation/pages/welcome_screen.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/client/domain/entities/client_user.dart';
import 'package:frontend/theme/app_theme.dart';

class AdminPanel extends ConsumerWidget {
  final int clientId;
  final String clientName;

  const AdminPanel({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  static const _panelColor = AppTheme.accent;
  static const _panelBorder = AppTheme.accent;

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(clientUsersNotifierProvider(clientId));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F8),
      appBar: AppBar(
        backgroundColor: _panelColor,
        foregroundColor: Colors.white,
        title: const Text('Mi Organización'),
        elevation: 0,
        // Botón de logout reemplaza el de atrás
        leading: IconButton(
          onPressed: () => _logout(context, ref),
          icon: const Icon(Icons.logout),
        ),
      ),
      body: RefreshIndicator(
        color: _panelColor,
        onRefresh: () =>
            ref.read(clientUsersNotifierProvider(clientId).notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              clientName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Resumen de usuarios asociados a tu organización.',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => _AddUserDialog(
                    clientId: clientId,
                    onAdd: (userId, role, isAdmin) => ref
                        .read(clientUsersNotifierProvider(clientId).notifier)
                        .addUser(userId, role, isAdmin),
                    onError: (message) =>
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            backgroundColor: Colors.redAccent,
                          ),
                        ),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar usuario'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _panelColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            usersAsync.when(
              loading: () => const _CenteredMessage(
                child: CircularProgressIndicator(color: _panelColor),
              ),
              error: (error, _) => _ErrorState(
                message: error is ApiException
                    ? error.message
                    : 'No se pudo cargar la organización.',
                onRetry: () => ref
                    .read(clientUsersNotifierProvider(clientId).notifier)
                    .refresh(),
              ),
              data: (users) => _UsersTable(clientId: clientId, users: users),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersTable extends StatelessWidget {
  final int clientId;
  final List<ClientUser> users;

  const _UsersTable({required this.clientId, required this.users});

  bool _hasAdminPrivileges(ClientUser user) {
    return user.isAdmin;
  }

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const _CenteredMessage(
        child: Text(
          'No hay usuarios asociados a esta organización.',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    final columnTextStyle = const TextStyle(
      color: AppTheme.accent,
      fontWeight: FontWeight.w700,
      fontSize: 14,
    );
    final cellTextStyle = const TextStyle(
      color: AppTheme.textPrimary,
      fontSize: 13,
    );

    const nameColumnWidth = 320.0;
    const roleColumnWidth = 210.0;
    const adminColumnWidth = 260.0;

    return Center(
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AdminPanel._panelBorder.withValues(alpha: 0.35),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: nameColumnWidth + roleColumnWidth + adminColumnWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TableRow(
                    isHeader: true,
                    children: [
                      _TableCell(
                        width: nameColumnWidth,
                        alignment: Alignment.centerLeft,
                        showLeftBorder: true,
                        child: Text('Usuarios', style: columnTextStyle),
                      ),
                      _TableCell(
                        width: roleColumnWidth,
                        alignment: Alignment.centerLeft,
                        child: Text('Roles', style: columnTextStyle),
                      ),
                      _TableCell(
                        width: adminColumnWidth,
                        alignment: Alignment.center,
                        child: Text(
                          'Tiene permisos administrativos',
                          style: columnTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  ...users.map(
                    (user) => _TableRow(
                      children: [
                        _TableCell(
                          width: nameColumnWidth,
                          alignment: Alignment.centerLeft,
                          showLeftBorder: true,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.user.name,
                                style: cellTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.user.email,
                                style: cellTextStyle.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        _TableCell(
                          width: roleColumnWidth,
                          alignment: Alignment.centerLeft,
                          child: Text(user.role, style: cellTextStyle),
                        ),
                        _TableCell(
                          width: adminColumnWidth,
                          alignment: Alignment.center,
                          child: _AdminPrivilegesCell(
                            clientId: clientId,
                            user: user,
                            isAdmin: _hasAdminPrivileges(user),
                            textStyle: cellTextStyle.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TableRow extends StatefulWidget {
  final List<Widget> children;
  final bool isHeader;

  const _TableRow({required this.children, this.isHeader = false});

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _hovered && !widget.isHeader ? Colors.grey.shade100 : null,
          border: Border(
            bottom: BorderSide(
              color: AppTheme.accent.withValues(
                alpha: widget.isHeader ? 0.35 : 0.2,
              ),
            ),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.children,
          ),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final double width;
  final Widget child;
  final Alignment alignment;
  final bool showLeftBorder;

  const _TableCell({
    required this.width,
    required this.child,
    required this.alignment,
    this.showLeftBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      alignment: alignment,
      decoration: BoxDecoration(
        border: Border(
          left: showLeftBorder
              ? BorderSide(color: AppTheme.accent.withValues(alpha: 0.26))
              : BorderSide.none,
          right: BorderSide(color: AppTheme.accent.withValues(alpha: 0.26)),
        ),
      ),
      child: child,
    );
  }
}

class _AdminPrivilegesCell extends StatefulWidget {
  final int clientId;
  final ClientUser user;
  final bool isAdmin;
  final TextStyle textStyle;

  const _AdminPrivilegesCell({
    required this.clientId,
    required this.user,
    required this.isAdmin,
    required this.textStyle,
  });

  @override
  State<_AdminPrivilegesCell> createState() => _AdminPrivilegesCellState();
}

class _AdminPrivilegesCellState extends State<_AdminPrivilegesCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => showDialog(
            context: context,
            builder: (_) => _EditAdminPrivilegesDialog(
              clientId: widget.clientId,
              user: widget.user,
              currentIsAdmin: widget.isAdmin,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              widget.isAdmin ? 'Sí' : 'No',
              textAlign: TextAlign.center,
              style: widget.textStyle.copyWith(
                decoration: _hovered
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditAdminPrivilegesDialog extends ConsumerStatefulWidget {
  final int clientId;
  final ClientUser user;
  final bool currentIsAdmin;

  const _EditAdminPrivilegesDialog({
    required this.clientId,
    required this.user,
    required this.currentIsAdmin,
  });

  @override
  ConsumerState<_EditAdminPrivilegesDialog> createState() =>
      _EditAdminPrivilegesDialogState();
}

class _EditAdminPrivilegesDialogState
    extends ConsumerState<_EditAdminPrivilegesDialog> {
  late bool _selectedIsAdmin;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedIsAdmin = widget.currentIsAdmin;
  }

  String get _currentPermissionsLabel =>
      widget.currentIsAdmin ? 'Administrador' : 'Ninguno';

  String get _selectedOptionLabel =>
      _selectedIsAdmin ? 'Administrador' : 'Ninguno';

  Future<void> _openConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Confirmar cambio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context, false),
              icon: const Icon(Icons.close),
              splashRadius: 20,
            ),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              children: [
                const TextSpan(
                  text: 'Usuario: ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: widget.user.user.name),
                const TextSpan(text: '\n'),
                const TextSpan(
                  text: 'Permisos actualizados: ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: _selectedOptionLabel),
              ],
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudieron actualizar los permisos.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'Modificando permisos de administrador para: ${widget.user.user.name}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permisos administrativos actuales: $_currentPermissionsLabel',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Seleccionar nuevos permisos administrativos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<bool>(
              initialValue: _selectedIsAdmin,
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
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: _saving ? null : _openConfirmationDialog,
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Confirmar'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return _CenteredMessage(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ocurrió un error',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AdminPanel._panelColor,
            ),
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final Widget child;

  const _CenteredMessage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 240),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _AddUserDialog extends ConsumerStatefulWidget {
  final int clientId;
  final Future<void> Function(int userId, String role, bool isAdmin) onAdd;
  final void Function(String) onError;

  const _AddUserDialog({
    required this.clientId,
    required this.onAdd,
    required this.onError,
  });

  @override
  ConsumerState<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends ConsumerState<_AddUserDialog> {
  String _selectedRole = 'doctor';
  bool _isAdmin = false;
  ClientUser? _selectedUser;
  List<ClientUser> _searchResults = [];
  bool _isSearching = false;
  bool _isSaving = false;
  final _emailCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _emailCtrl.dispose();
    super.dispose();
  }

  bool get _adminForced => _selectedRole == 'administrador';

  void _onSearchChanged(String value) {
    if (_selectedUser != null) {
      setState(() {
        _selectedUser = null;
        _searchResults = [];
      });
    }
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() => _isSearching = true);
      try {
        final results = await ref.read(
          availableUsersForClientProvider((
            clientId: widget.clientId,
            search: value.trim(),
          )).future,
        );
        if (!mounted) return;
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  double get _resultsPanelHeight {
    const rowHeight = 58.0;
    const maxHeight = 180.0;
    return math.min(_searchResults.length * rowHeight, maxHeight);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Agregar usuario'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _selectedUser != null
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 8),
            if (_searchResults.isNotEmpty && _selectedUser == null)
              Container(
                height: _resultsPanelHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Material(
                    color: Colors.white,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      itemBuilder: (_, i) {
                        final user = _searchResults[i];
                        return InkWell(
                          onTap: () {
                            _debounce?.cancel();
                            setState(() {
                              _selectedUser = user;
                              _searchResults = [];
                              _emailCtrl.text = user.user.email;
                            });
                          },
                          child: SizedBox(
                            height: 58,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.user.name,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.user.email,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Rol',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                DropdownMenuItem(
                  value: 'secretaria',
                  child: Text('Secretaria'),
                ),
                DropdownMenuItem(
                  value: 'administrador',
                  child: Text('Administrador'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedRole = value;
                  if (value == 'administrador') _isAdmin = true;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<bool>(
              value: _adminForced ? true : _isAdmin,
              decoration: InputDecoration(
                labelText: 'Permisos administrativos',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: true, child: Text('Administrador')),
                DropdownMenuItem(value: false, child: Text('Ninguno')),
              ],
              onChanged: _adminForced
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() => _isAdmin = value);
                    },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _isSaving || _selectedUser == null
                    ? null
                    : () async {
                        setState(() => _isSaving = true);
                        try {
                          await widget.onAdd(
                            _selectedUser!.user.id,
                            _selectedRole,
                            _adminForced ? true : _isAdmin,
                          );
                          if (context.mounted) Navigator.pop(context);
                        } on ApiException catch (e) {
                          widget.onError(e.message);
                        } catch (_) {
                          widget.onError('Error al agregar el usuario.');
                        } finally {
                          if (mounted) setState(() => _isSaving = false);
                        }
                      },
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
