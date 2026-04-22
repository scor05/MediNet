import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/admin/presentation/providers/clients_provider.dart';
import 'package:frontend/features/user/domain/entities/user.dart';
import 'package:frontend/features/user/domain/providers/user_domain_providers.dart';

class CreateClientDialog extends ConsumerStatefulWidget {
  const CreateClientDialog({super.key});

  @override
  ConsumerState<CreateClientDialog> createState() => _CreateClientDialogState();
}

class _CreateClientDialogState extends ConsumerState<CreateClientDialog> {
  final nameCtrl = TextEditingController();
  final nitCtrl = TextEditingController();
  final adminEmailCtrl = TextEditingController();

  User? selectedAdmin;
  List<User> searchResults = [];
  bool isSearching = false;
  bool isSubmitting = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    nameCtrl.dispose();
    nitCtrl.dispose();
    adminEmailCtrl.dispose();
    super.dispose();
  }

  void _onAdminSearchChanged(String value) {
    if (selectedAdmin != null) {
      setState(() {
        selectedAdmin = null;
        searchResults = [];
      });
    }

    _debounce?.cancel();

    if (value.trim().length < 2) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;

      setState(() => isSearching = true);

      try {
        final results = await ref
            .read(getAvailableUsersUsecaseProvider)
            .call(value.trim());

        if (!mounted) return;

        setState(() {
          searchResults = results;
          isSearching = false;
        });
      } catch (_) {
        if (!mounted) return;

        setState(() {
          searchResults = [];
          isSearching = false;
        });
      }
    });
  }

  Future<void> _submit() async {
    final name = nameCtrl.text.trim();
    final nit = nitCtrl.text.trim();

    if (name.isEmpty || nit.isEmpty) return;

    setState(() => isSubmitting = true);

    try {
      await ref
          .read(clientsNotifierProvider.notifier)
          .createClient(name: name, nit: nit, userId: selectedAdmin?.id);

      if (context.mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear el cliente.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 400,
        height: 460,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Título ────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Text(
                'Nuevo cliente',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),

            // ── Contenido ─────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const SizedBox(height: 16),

                    const Text(
                      'Usuario Administrador (opcional)',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                    const SizedBox(height: 6),

                    TextField(
                      controller: adminEmailCtrl,
                      decoration: _inputDecoration('Buscar por email').copyWith(
                        suffixIcon: isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : selectedAdmin != null
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : null,
                      ),
                      onChanged: _onAdminSearchChanged,
                    ),

                    const SizedBox(height: 8),

                    if (searchResults.isNotEmpty && selectedAdmin == null)
                      Expanded(
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
                                    selectedAdmin = user;
                                    searchResults = [];
                                    adminEmailCtrl.text = user.email;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),

                    if (selectedAdmin != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.black45,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              selectedAdmin!.name,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              selectedAdmin = null;
                              adminEmailCtrl.clear();
                            }),
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isSubmitting ? null : _submit,
                    child: isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Crear'),
                  ),
                ],
              ),
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
