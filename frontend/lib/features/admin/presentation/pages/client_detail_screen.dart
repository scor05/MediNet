import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/core/widgets/error_view.dart';
import 'package:frontend/features/admin/presentation/dialogs/add_user_dialog.dart';
import 'package:frontend/features/admin/presentation/dialogs/edit_client_dialog.dart';
import 'package:frontend/features/admin/presentation/providers/client_clinics_provider.dart';
import 'package:frontend/features/admin/presentation/providers/client_users_provider.dart';
import 'package:frontend/features/admin/presentation/providers/clients_provider.dart';
import 'package:frontend/features/admin/presentation/widgets/client_detail/client_detail_content.dart';
import 'package:frontend/features/client/domain/entities/client.dart';
import 'package:frontend/theme/app_theme.dart';

class ClientDetailScreen extends ConsumerStatefulWidget {
  final int clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _togglingStatus = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleStatus() async {
    if (_togglingStatus) return;

    setState(() => _togglingStatus = true);

    try {
      await ref
          .read(clientsNotifierProvider.notifier)
          .toggleStatus(widget.clientId);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Error inesperado. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _togglingStatus = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showEditDialog(Client client) {
    showDialog(
      context: context,
      builder: (_) => EditClientDialog(
        initialName: client.name,
        initialNit: client.nit,
        onSave: (name, nit) async {
          try {
            await ref
                .read(clientsNotifierProvider.notifier)
                .editClient(widget.clientId, name: name, nit: nit);
          } on ApiException catch (e) {
            _showError(e.message);
          } catch (_) {
            _showError('Error al guardar los cambios.');
          }
        },
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (_) => AddUserDialog(
        clientId: widget.clientId,
        onAdd: (userId, role, isAdmin) async {
          await ref
              .read(clientUsersNotifierProvider(widget.clientId).notifier)
              .addUser(userId, role, isAdmin);
        },
        onError: _showError,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientsState = ref.watch(clientsNotifierProvider);
    final usersAsync = ref.watch(clientUsersNotifierProvider(widget.clientId));
    final clinicsAsync = ref.watch(
      clientClinicsNotifierProvider(widget.clientId),
    );

    final clientAsync = clientsState.whenData(
      (clients) => clients.firstWhere((client) => client.id == widget.clientId),
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: clientAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
        error: (error, _) => ErrorView(
          message: 'No se pudo cargar el cliente.',
          onRetry: ref.read(clientsNotifierProvider.notifier).refresh,
        ),
        data: (client) => ClientDetailContent(
          client: client,
          usersAsync: usersAsync,
          clinicsAsync: clinicsAsync,
          tabController: _tabController,
          togglingStatus: _togglingStatus,
          onBack: () => Navigator.pop(context),
          onToggleStatus: _toggleStatus,
          onEditClient: () => _showEditDialog(client),
          onAddUser: _showAddUserDialog,
          onAddClinic: () {},
          onRetryUsers: () => ref
              .read(clientUsersNotifierProvider(widget.clientId).notifier)
              .refresh(),
          onRetryClinics: () => ref
              .read(clientClinicsNotifierProvider(widget.clientId).notifier)
              .refresh(),
        ),
      ),
    );
  }
}
