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
              data: (users) => _UsersTable(users: users),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersTable extends StatelessWidget {
  final List<User> users;

  const _UsersTable({required this.users});

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

    return Center(
      child: DecoratedBox(
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
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: AppTheme.accent.withValues(alpha: 0.25)),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.transparent),
                dataRowMinHeight: 64,
                dataRowMaxHeight: 76,
                horizontalMargin: 28,
                columnSpacing: 8,
                columns: [
                  DataColumn(
                    label: SizedBox(
                      width: 320,
                      child: Text('Usuarios', style: columnTextStyle),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 210,
                      child: Text('Roles', style: columnTextStyle),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 260,
                      child: Text(
                        'Tiene permisos administrativos',
                        style: columnTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
                rows: users
                    .map(
                      (user) => DataRow(
                        color: WidgetStateProperty.all(Colors.transparent),
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 320,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                          ),
                          DataCell(
                            SizedBox(
                              width: 210,
                              child: Text(user.role, style: cellTextStyle),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 260,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  _hasAdminPrivileges(user) ? 'Sí' : 'No',
                                  textAlign: TextAlign.center,
                                  style: cellTextStyle.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
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
