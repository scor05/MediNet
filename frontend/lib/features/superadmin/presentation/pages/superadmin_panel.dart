import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import '../../domain/entities/client.dart';
import '../providers/clients_provider.dart';
import '../widgets/client_card.dart';
import '../widgets/client_filter_chip.dart';

class SuperadminPanel extends ConsumerStatefulWidget {
  const SuperadminPanel({super.key});

  @override
  ConsumerState<SuperadminPanel> createState() => _SuperadminPanelState();
}

class _SuperadminPanelState extends ConsumerState<SuperadminPanel> {
  // IDs de clientes cuyo toggle está en curso (para mostrar spinner individual)
  final Set<int> _togglingIds = {};

  Future<void> _toggleStatus(Client client) async {
    if (_togglingIds.contains(client.id)) return;

    setState(() => _togglingIds.add(client.id));

    try {
      await ref.read(clientsNotifierProvider.notifier).toggleStatus(client);
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

  @override
  Widget build(BuildContext context) {
    // ref.watch hace que el widget se reconstruya cuando cambia el provider
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

  // ─── Header ───────────────────────────────────────────────────────────────

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
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
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
                      'Clientes',
                      style: TextStyle(
                        color: AppTheme.background,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
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
                onPressed: () {
                  // TODO: navegar a pantalla de crear cliente
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Nuevo',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Filter bar ───────────────────────────────────────────────────────────

  Widget _buildFilterBar(bool? currentFilter) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          ClientFilterChip(
            label: 'Todos',
            selected: currentFilter == null,
            // ref.read para escrituras puntuales (no necesita observar cambios)
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

  // ─── Estados ──────────────────────────────────────────────────────────────

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
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.redAccent.shade200,
            ),
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
              // TODO: navegar a pantalla de detalle
            },
            onToggle: () => _toggleStatus(client),
          );
        },
      ),
    );
  }
}
