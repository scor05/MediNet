import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/client_admin/presentation/providers/organization_users_provider.dart';
import 'package:frontend/features/superadmin/domain/entities/user.dart';
import 'package:frontend/theme/app_theme.dart';

class OrganizationDashboardScreen extends ConsumerWidget {
  final int clientId;
  final String clientName;

  const OrganizationDashboardScreen({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  static const _panelColor = AppTheme.accent;
  static const _panelBorder = AppTheme.accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(organizationUsersNotifierProvider(clientId));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F8),
      appBar: AppBar(
        backgroundColor: _panelColor,
        foregroundColor: Colors.white,
        title: const Text('Mi Organización'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: _panelColor,
        onRefresh: () => ref
            .read(organizationUsersNotifierProvider(clientId).notifier)
            .refresh(),
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
                    .read(organizationUsersNotifierProvider(clientId).notifier)
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
  final List<User> users;

  const _UsersTable({required this.clientId, required this.users});

  bool _hasAdminPrivileges(User user) {
    return user.isAdmin || user.role == 'Administrador';
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
            color: OrganizationDashboardScreen._panelBorder.withValues(
              alpha: 0.35,
            ),
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
                                user.name,
                                style: cellTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
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
  final User user;
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
  final User user;
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
                TextSpan(text: widget.user.name),
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
          .read(organizationUsersNotifierProvider(widget.clientId).notifier)
          .updateAdminPrivileges(
            userId: widget.user.id,
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
        'Modificando permisos de administrador para: ${widget.user.name}',
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
              backgroundColor: OrganizationDashboardScreen._panelColor,
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
