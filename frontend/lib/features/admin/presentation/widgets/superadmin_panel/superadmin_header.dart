import 'package:flutter/material.dart';
import 'package:frontend/features/admin/presentation/widgets/superadmin_panel/create_client_dialog.dart';
import 'package:frontend/theme/app_theme.dart';

class SuperadminHeader extends StatelessWidget {
  final VoidCallback onLogout;

  const SuperadminHeader({super.key, required this.onLogout});

  void _openCreateClientDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const CreateClientDialog());
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: onLogout,
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
                  onPressed: () => _openCreateClientDialog(context),
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
}
