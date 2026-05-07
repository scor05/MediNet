import 'package:flutter/material.dart';
import 'package:frontend/features/admin/presentation/widgets/superadmin_panel/client_card.dart';
import 'package:frontend/features/client/domain/entities/client.dart';
import 'package:frontend/theme/app_theme.dart';

class ClientsListView extends StatelessWidget {
  final List<Client> clients;
  final Set<int> togglingIds;
  final Future<void> Function() onRefresh;
  final ValueChanged<Client> onOpenClient;
  final ValueChanged<Client> onToggleClient;

  const ClientsListView({
    super.key,
    required this.clients,
    required this.togglingIds,
    required this.onRefresh,
    required this.onOpenClient,
    required this.onToggleClient,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: clients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final client = clients[index];

          return ClientCard(
            client: client,
            toggling: togglingIds.contains(client.id),
            onTap: () => onOpenClient(client),
            onToggle: () => onToggleClient(client),
          );
        },
      ),
    );
  }
}
