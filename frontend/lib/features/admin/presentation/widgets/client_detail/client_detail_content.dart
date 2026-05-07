import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/admin/presentation/widgets/client_detail/client_detail_async_list.dart';
import 'package:frontend/features/admin/presentation/widgets/client_detail/client_detail_header.dart';
import 'package:frontend/features/admin/presentation/widgets/client_detail/clinic_tile.dart';
import 'package:frontend/features/admin/presentation/widgets/client_detail/user_tile.dart';
import 'package:frontend/features/client/domain/entities/client.dart';
import 'package:frontend/features/client/domain/entities/client_user.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/theme/app_theme.dart';

class ClientDetailContent extends StatelessWidget {
  final Client client;
  final AsyncValue<List<ClientUser>> usersAsync;
  final AsyncValue<List<Clinic>> clinicsAsync;
  final TabController tabController;
  final bool togglingStatus;
  final VoidCallback onBack;
  final VoidCallback onToggleStatus;
  final VoidCallback onEditClient;
  final VoidCallback onAddUser;
  final VoidCallback onAddClinic;
  final VoidCallback onRetryUsers;
  final VoidCallback onRetryClinics;

  const ClientDetailContent({
    super.key,
    required this.client,
    required this.usersAsync,
    required this.clinicsAsync,
    required this.tabController,
    required this.togglingStatus,
    required this.onBack,
    required this.onToggleStatus,
    required this.onEditClient,
    required this.onAddUser,
    required this.onAddClinic,
    required this.onRetryUsers,
    required this.onRetryClinics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClientDetailHeader(
          name: client.name,
          nit: client.nit,
          isActive: client.isActive,
          loadingStatus: togglingStatus,
          onBack: onBack,
          onEdit: onEditClient,
          onToggleStatus: onToggleStatus,
        ),
        TabBar(
          controller: tabController,
          labelColor: AppTheme.accent,
          unselectedLabelColor: Colors.black45,
          indicatorColor: AppTheme.accent,
          tabs: [
            Tab(
              text:
                  usersAsync.whenOrNull(
                    data: (users) => 'Usuarios (${users.length})',
                  ) ??
                  'Usuarios',
            ),
            Tab(
              text:
                  clinicsAsync.whenOrNull(
                    data: (clinics) => 'Clínicas (${clinics.length})',
                  ) ??
                  'Clínicas',
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              ClientDetailAsyncList<ClientUser>(
                asyncValue: usersAsync,
                listLabel: 'Usuarios',
                emptyLabel: 'No hay usuarios registrados',
                onRetry: onRetryUsers,
                onAdd: onAddUser,
                itemBuilder: (user) => UserTile(user: user, onDelete: () {}),
              ),
              ClientDetailAsyncList<Clinic>(
                asyncValue: clinicsAsync,
                listLabel: 'Clínicas',
                emptyLabel: 'No hay clínicas registradas',
                onRetry: onRetryClinics,
                onAdd: onAddClinic,
                itemBuilder: (clinic) =>
                    ClinicTile(clinic: clinic, onDelete: () {}),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
