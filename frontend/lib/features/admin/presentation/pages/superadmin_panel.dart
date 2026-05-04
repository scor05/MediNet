import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/admin/presentation/pages/client_detail_screen.dart';
import 'package:frontend/features/admin/presentation/providers/clients_provider.dart';
import 'package:frontend/features/admin/presentation/widgets/client_card.dart';
import 'package:frontend/features/admin/presentation/widgets/client_filter_chip.dart';
import 'package:frontend/features/admin/presentation/widgets/create_client_dialog.dart';
import 'package:frontend/features/auth/presentation/pages/welcome_screen.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error inesperado. Intenta de nuevo.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _togglingIds.remove(client.id));
    }
  }

  // Logout: cierra sesión, limpia estado y redirige al WelcomeScreen
  Future<void> _logout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
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
          _buildHeader(context),
          _buildFilterBar(filter),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.accent),
              ),
              error: (error, _) => _buildError(error),
              data: (clients) =>
                  clients.isEmpty ? _buildEmpty(filter) : _buildList(clients),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.accent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Row(
            children: [
              // Botón de logout reemplaza el de atrás
              IconButton(
                onPressed: _logout,
                icon: const Icon(
                  Icons.logout,
                  color: AppTheme.background,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MEDINET',
                      style: TextStyle(
                        color: AppTheme.background,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        color: AppTheme.background,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.background,
                    foregroundColor: AppTheme.accent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const CreateClientDialog(),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'Nuevo cliente',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(bool? currentFilter) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          ClientFilterChip(
            label: 'Todos',
            selected: currentFilter == null,
            onTap: () => ref.read(clientFilterProvider.notifier).state = null,
          ),
          const SizedBox(width: 8),
          ClientFilterChip(
            label: 'Activos',
            selected: currentFilter == true,
            onTap: () => ref.read(clientFilterProvider.notifier).state = true,
          ),
          const SizedBox(width: 8),
          ClientFilterChip(
            label: 'Inactivos',
            selected: currentFilter == false,
            onTap: () => ref.read(clientFilterProvider.notifier).state = false,
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error) {
    final message = error is ApiException
        ? error.message
        : 'Error inesperado. Intenta de nuevo.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.redAccent.shade200),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: AppTheme.btnDark,
              onPressed: () =>
                  ref.read(clientsNotifierProvider.notifier).refresh(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool? filter) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, size: 48, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            filter == null
                ? 'No hay clientes registrados'
                : filter
                ? 'No hay clientes activos'
                : 'No hay clientes inactivos',
            style: const TextStyle(color: Colors.black45, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Client> clients) {
    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: () => ref.read(clientsNotifierProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: clients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final client = clients[index];
          return ClientCard(
            client: client,
            toggling: _togglingIds.contains(client.id),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientDetailScreen(clientId: client.id),
                ),
              );
            },
            onToggle: () => _toggleStatus(client),
          );
        },
      ),
    );
  }
}