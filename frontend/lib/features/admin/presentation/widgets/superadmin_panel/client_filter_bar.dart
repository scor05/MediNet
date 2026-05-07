import 'package:flutter/material.dart';
import 'package:frontend/features/admin/presentation/widgets/superadmin_panel/client_filter_chip.dart';
import 'package:frontend/theme/app_theme.dart';

class ClientFilterBar extends StatelessWidget {
  final bool? currentFilter;
  final ValueChanged<bool?> onChanged;

  const ClientFilterBar({
    super.key,
    required this.currentFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          ClientFilterChip(
            label: 'Todos',
            selected: currentFilter == null,
            onTap: () => onChanged(null),
          ),
          const SizedBox(width: 8),
          ClientFilterChip(
            label: 'Activos',
            selected: currentFilter == true,
            onTap: () => onChanged(true),
          ),
          const SizedBox(width: 8),
          ClientFilterChip(
            label: 'Inactivos',
            selected: currentFilter == false,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}
