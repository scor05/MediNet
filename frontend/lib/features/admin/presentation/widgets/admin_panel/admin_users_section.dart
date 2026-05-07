import 'package:flutter/material.dart';
import 'package:frontend/features/admin/presentation/widgets/admin_panel/admin_empty_users_view.dart';
import 'package:frontend/features/admin/presentation/widgets/admin_panel/admin_user_card.dart';
import 'package:frontend/features/client/domain/entities/client_user.dart';
import 'package:frontend/theme/app_theme.dart';

class AdminUsersSection extends StatelessWidget {
  final int clientId;
  final List<ClientUser> users;

  const AdminUsersSection({
    super.key,
    required this.clientId,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const AdminEmptyUsersView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usuarios (${users.length})',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...users.map(
          (user) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AdminUserCard(clientId: clientId, user: user),
          ),
        ),
      ],
    );
  }
}
