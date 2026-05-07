import 'package:flutter/material.dart';
import 'package:frontend/features/admin/presentation/widgets/client_detail/status_toggle.dart';
import 'package:frontend/theme/app_theme.dart';

class ClientDetailHeader extends StatelessWidget {
  final String name;
  final String nit;
  final bool isActive;
  final bool loadingStatus;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;

  const ClientDetailHeader({
    super.key,
    required this.name,
    required this.nit,
    required this.isActive,
    required this.loadingStatus,
    required this.onBack,
    required this.onEdit,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
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
                onPressed: onBack,
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
                          onTap: onEdit,
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
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StatusToggle(
                isActive: isActive,
                loading: loadingStatus,
                onTap: onToggleStatus,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
