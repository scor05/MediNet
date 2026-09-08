import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/core/widgets/error_view.dart';
import 'package:frontend/features/admin/presentation/dialogs/add_user_dialog.dart';
import 'package:frontend/features/admin/presentation/providers/client_users_provider.dart';
import 'package:frontend/features/admin/presentation/widgets/admin_panel/admin_client_header.dart';
import 'package:frontend/features/admin/presentation/widgets/admin_panel/admin_users_section.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';
import 'package:frontend/features/auth/presentation/utils/logout_helper.dart';
import 'package:frontend/features/calendar/presentation/pages/settings_screen.dart';
import 'package:frontend/theme/app_theme.dart';

class AdminPanel extends ConsumerStatefulWidget {
  final int clientId;
  final String clientName;
  final UserProfile profile;

  const AdminPanel({
    super.key,
    required this.clientId,
    required this.clientName,
    required this.profile,
  });

  @override
  ConsumerState<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends ConsumerState<AdminPanel> {
  bool _showSettings = false;

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _openAddUserDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AddUserDialog(
        clientId: widget.clientId,
        onAdd: (userId, role, isAdmin) {
          return ref
              .read(clientUsersNotifierProvider(widget.clientId).notifier)
              .addUser(userId, role, isAdmin);
        },
        onError: (message) => _showError(context, message),
      ),
    );
  }

  Future<void> _refreshUsers(WidgetRef ref) {
    return ref
        .read(clientUsersNotifierProvider(widget.clientId).notifier)
        .refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSettings) {
      return SettingsScreen(
        profile: widget.profile,
        onBack: () => setState(() => _showSettings = false),
      );
    }

    final usersAsync = ref.watch(clientUsersNotifierProvider(widget.clientId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mi Organización'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => logoutAndGoToWelcome(context: context, ref: ref),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              tooltip: 'Ajustes',
              icon: const Icon(Icons.settings),
              onPressed: () => setState(() => _showSettings = true),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.accent,
        onRefresh: () => _refreshUsers(ref),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            AdminClientHeader(
              clientName: widget.clientName,
              onAddUser: () => _openAddUserDialog(context, ref),
            ),
            const SizedBox(height: 20),

            usersAsync.when(
              loading: () => const SizedBox(
                height: 240,
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.accent),
                ),
              ),
              error: (error, _) {
                final message = error is ApiException
                    ? error.message
                    : 'No se pudo cargar la organización.';

                return ErrorView(
                  message: message,
                  onRetry: () => _refreshUsers(ref),
                );
              },
              data: (users) =>
                  AdminUsersSection(clientId: widget.clientId, users: users),
            ),
          ],
        ),
      ),
    );
  }
}
