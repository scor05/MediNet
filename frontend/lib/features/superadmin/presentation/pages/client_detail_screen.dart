import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/clinic.dart';
import '../providers/clients_provider.dart';
import '../providers/client_users_provider.dart';
import '../providers/client_clinics_provider.dart';
import 'dart:async';

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

  // ── Acciones ──────────────────────────────────────────────

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

  void _showEditDialog(String currentName, String currentNit) {
    final nameCtrl = TextEditingController(text: currentName);
    final nitCtrl = TextEditingController(text: currentNit);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: _inputDecoration('Nombre'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nitCtrl,
              decoration: _inputDecoration('NIT'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final nit = nitCtrl.text.trim();
              if (name.isEmpty || nit.isEmpty) return;
              Navigator.pop(ctx);
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
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _AddUserDialog(
        clientId: widget.clientId,
        onAdd: (userId, role, isAdmin) async {
          await ref
              .read(clientUsersNotifierProvider(widget.clientId).notifier)
              .addUser(userId, role, isAdmin);
        },
        onError: (message) => _showError(message),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Lee el cliente directamente de la lista del panel.
    // Cualquier cambio (toggle, edit) reconstruye esta pantalla automáticamente.
    final clientsState = ref.watch(clientsNotifierProvider);
    final usersAsync = ref.watch(clientUsersNotifierProvider(widget.clientId));
    final clinicsAsync = ref.watch(
      clientClinicsNotifierProvider(widget.clientId),
    );

    // Se deriva el cliente de la lista. Si la lista aún está cargando o falló,
    // se muestran los estados correspondientes.
    final clientAsync = clientsState.whenData(
      (list) => list.firstWhere((c) => c.id == widget.clientId),
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: clientAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
        error: (e, _) => _buildClientError(),
        data: (client) => _buildContent(client, usersAsync, clinicsAsync),
      ),
    );
  }

  Widget _buildContent(
    Client client,
    AsyncValue<List<User>> usersAsync,
    AsyncValue<List<Clinic>> clinicsAsync,
  ) {
    return Column(
      children: [
        _buildHeader(
          name: client.name,
          nit: client.nit,
          isActive: client.isActive,
        ),
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.accent,
          unselectedLabelColor: Colors.black45,
          indicatorColor: AppTheme.accent,
          tabs: [
            Tab(
              text:
                  usersAsync.whenOrNull(
                    data: (u) => 'Usuarios (${u.length})',
                  ) ??
                  'Usuarios',
            ),
            Tab(
              text:
                  clinicsAsync.whenOrNull(
                    data: (c) => 'Clínicas (${c.length})',
                  ) ??
                  'Clínicas',
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAsyncList(
                asyncValue: usersAsync,
                listLabel: 'Usuarios',
                emptyLabel: 'No hay usuarios registrados',
                onRetry: () => ref
                    .read(clientUsersNotifierProvider(widget.clientId).notifier)
                    .refresh(),
                onAdd: () => _showAddUserDialog(),
                itemBuilder: (i) => _UserTile(
                  user: usersAsync.requireValue[i],
                  onDelete: () {}, // TODO
                ),
              ),
              _buildAsyncList(
                asyncValue: clinicsAsync,
                listLabel: 'Clínicas',
                emptyLabel: 'No hay clínicas registradas',
                onRetry: () => ref
                    .read(
                      clientClinicsNotifierProvider(widget.clientId).notifier,
                    )
                    .refresh(),
                onAdd: () {}, // TODO
                itemBuilder: (i) => _ClinicTile(
                  clinic: clinicsAsync.requireValue[i],
                  onDelete: () {}, // TODO
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────

  Widget _buildHeader({
    required String name,
    required String nit,
    required bool isActive,
  }) {
    return Container(
      width: double.infinity,
      color: AppTheme.accent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MEDINET',
                      style: TextStyle(
                        color: AppTheme.background,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: AppTheme.background,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showEditDialog(name, nit),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: AppTheme.background,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NIT: $nit',
                      style: const TextStyle(
                        color: AppTheme.background,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusToggle(
                isActive: isActive,
                loading: _togglingStatus,
                onTap: _toggleStatus,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Lista genérica ────────────────────────────────────────

  Widget _buildAsyncList({
    required AsyncValue asyncValue,
    required String listLabel,
    required String emptyLabel,
    required VoidCallback onRetry,
    required VoidCallback onAdd,
    required Widget Function(int index) itemBuilder,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                listLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
              ),
            ],
          ),
        ),
        Expanded(
          child: asyncValue.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            ),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Colors.redAccent.shade200,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    e is ApiException ? e.message : 'Error inesperado.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: AppTheme.btnDark,
                    onPressed: onRetry,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
            data: (items) => (items as List).isEmpty
                ? _EmptyState(label: emptyLabel)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => itemBuilder(i),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Error del cliente (raro — solo si el panel falló) ─────

  Widget _buildClientError() {
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
            const Text(
              'No se pudo cargar el cliente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black54),
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

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatusToggle extends StatelessWidget {
  final bool isActive;
  final bool loading;
  final VoidCallback onTap;

  const _StatusToggle({
    required this.isActive,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white54),
        ),
        child: loading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isActive ? 'Activo' : 'Inactivo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final User user;
  final VoidCallback onDelete;

  const _UserTile({required this.user, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.accent.withValues(alpha: 0.15),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.role,
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _ClinicTile extends StatelessWidget {
  final Clinic clinic;
  final VoidCallback onDelete;

  const _ClinicTile({required this.clinic, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_hospital_outlined,
            color: AppTheme.accent,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              clinic.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(color: Colors.black45, fontSize: 14),
      ),
    );
  }
}

class _AdminOption extends StatelessWidget {
  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const _AdminOption({
    required this.label,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected && !disabled
              ? AppTheme.accent
              : disabled
              ? Colors.black12
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected && !disabled ? AppTheme.accent : Colors.black26,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected && !disabled
                ? Colors.white
                : disabled
                ? Colors.black38
                : Colors.black54,
          ),
        ),
      ),
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
  String selectedRole = 'doctor';
  bool isAdmin = false;
  User? selectedUser;
  List<User> searchResults = [];
  bool isSearching = false;
  final emailCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    emailCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (selectedUser != null) {
      setState(() {
        selectedUser = null;
        searchResults = [];
      });
    }

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() => isSearching = true);
      try {
        final results = await ref.read(
          availableUsersForClientProvider((
            clientId: widget.clientId,
            search: value.trim(),
          )).future,
        );

        if (!mounted) {
          return;
        }
        setState(() {
          searchResults = results;
          isSearching = false;
        });
      } catch (e, st) {
        if (!mounted) return;
        setState(() {
          searchResults = [];
          isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar usuario'),
      content: SizedBox(
        width: 400,
        height: 450, // 🔥 CLAVE: tamaño fijo
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : selectedUser != null
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),

            const SizedBox(height: 8),

            if (searchResults.isNotEmpty && selectedUser == null)
              Expanded(
                // 🔥 CLAVE
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (_, i) {
                      final user = searchResults[i];
                      return ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        onTap: () {
                          _debounce?.cancel();
                          setState(() {
                            selectedUser = user;
                            searchResults = [];
                            emailCtrl.text = user.email;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedRole,
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
                  selectedRole = value;
                  if (value == 'administrador') isAdmin = true;
                });
              },
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Expanded(child: Text('¿Es administrador?')),
                _AdminOption(
                  label: 'Sí',
                  selected: isAdmin,
                  disabled: selectedRole == 'administrador',
                  onTap: () => setState(() => isAdmin = true),
                ),
                const SizedBox(width: 8),
                _AdminOption(
                  label: 'No',
                  selected: !isAdmin,
                  disabled: selectedRole == 'administrador',
                  onTap: () => setState(() => isAdmin = false),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (selectedUser == null) return;

            try {
              await widget.onAdd(selectedUser!.id, selectedRole, isAdmin);
              if (context.mounted) Navigator.pop(context);
            } on ApiException catch (e) {
              widget.onError(e.message);
            } catch (_) {
              widget.onError('Error al agregar el usuario.');
            }
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
