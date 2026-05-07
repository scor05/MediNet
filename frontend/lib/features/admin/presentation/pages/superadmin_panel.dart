import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/core/widgets/error_view.dart';
import 'package:frontend/features/admin/presentation/pages/client_detail_screen.dart';
import 'package:frontend/features/admin/presentation/providers/clients_provider.dart';
import 'package:frontend/features/admin/presentation/widgets/superadmin_panel/client_filter_bar.dart';
import 'package:frontend/features/admin/presentation/widgets/superadmin_panel/clients_empty_view.dart';
import 'package:frontend/features/admin/presentation/widgets/superadmin_panel/clients_list_view.dart';
import 'package:frontend/features/admin/presentation/widgets/superadmin_panel/superadmin_header.dart';
import 'package:frontend/features/auth/presentation/utils/logout_helper.dart';
import 'package:frontend/features/client/domain/entities/client.dart';
import 'package:frontend/theme/app_theme.dart';

class SuperadminPanel extends ConsumerStatefulWidget {
  const SuperadminPanel({super.key});

  @override
  ConsumerState<SuperadminPanel> createState() => _SuperadminPanelState();
}

class _SuperadminPanelState extends ConsumerState<SuperadminPanel> {
  final Set<int> _togglingIds = {};

  Future<void> _toggleStatus(Client client) async {
    if (_togglingIds.contains(client.id)) return;

    setState(() => _togglingIds.add(client.id));

    try {
      await ref.read(clientsNotifierProvider.notifier).toggleStatus(client.id);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Error inesperado. Intenta de nuevo.');
    } finally {
      if (mounted) {
        setState(() => _togglingIds.remove(client.id));
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  Future<void> _logout() async {
    await logoutAndGoToWelcome(context: context, ref: ref);
  }

  void _openClientDetail(Client client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientDetailScreen(clientId: client.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredClientsProvider);
    final filter = ref.watch(clientFilterProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          SuperadminHeader(onLogout: _logout),
          ClientFilterBar(
            currentFilter: filter,
            onChanged: (value) {
              ref.read(clientFilterProvider.notifier).state = value;
            },
          ),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.accent),
              ),
              error: (error, _) {
                final message = error is ApiException
                    ? error.message
                    : 'Error inesperado. Intenta de nuevo.';

                return ErrorView(
                  message: message,
                  onRetry: ref.read(clientsNotifierProvider.notifier).refresh,
                );
              },
              data: (clients) {
                if (clients.isEmpty) {
                  return ClientsEmptyView(filter: filter);
                }

                return ClientsListView(
                  clients: clients,
                  togglingIds: _togglingIds,
                  onRefresh: ref.read(clientsNotifierProvider.notifier).refresh,
                  onOpenClient: _openClientDetail,
                  onToggleClient: _toggleStatus,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
