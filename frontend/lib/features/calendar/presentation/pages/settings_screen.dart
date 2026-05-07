import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/services/default_role_service.dart';
import 'package:frontend/features/auth/presentation/utils/auth_role_labels.dart';
import 'package:frontend/features/auth/presentation/utils/logout_helper.dart';
import 'package:frontend/features/calendar/presentation/widgets/settings/default_role_card.dart';
import 'package:frontend/features/calendar/presentation/widgets/settings/logout_card.dart';
import 'package:frontend/features/calendar/presentation/widgets/settings/settings_section_description.dart';
import 'package:frontend/features/calendar/presentation/widgets/settings/settings_section_title.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final List<String> roles;

  const SettingsScreen({super.key, this.roles = const []});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _defaultRole;
  bool _loadingDefaultRole = true;

  @override
  void initState() {
    super.initState();
    _loadDefaultRole();
  }

  Future<void> _loadDefaultRole() async {
    final role = await DefaultRoleService.getDefaultRole();

    if (!mounted) return;

    setState(() {
      _defaultRole = role;
      _loadingDefaultRole = false;
    });
  }

  Future<void> _onDefaultRoleChanged(String? role) async {
    setState(() => _defaultRole = role);

    await DefaultRoleService.setDefaultRole(role);

    if (!mounted) return;

    final message = role == null
        ? 'Rol predeterminado eliminado'
        : 'Rol predeterminado: ${AuthRoleLabels.label(role)}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _logout() async {
    await logoutAndGoToWelcome(context: context, ref: ref);
  }

  @override
  Widget build(BuildContext context) {
    final showRoleSelector = widget.roles.length > 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          if (showRoleSelector) ...[
            const SettingsSectionTitle(title: 'Rol predeterminado'),
            const SizedBox(height: 4),
            const SettingsSectionDescription(
              text:
                  'Selecciona el rol con el que quieres iniciar sesión automáticamente.',
            ),
            const SizedBox(height: 12),
            DefaultRoleCard(
              roles: widget.roles,
              selectedRole: _defaultRole,
              loading: _loadingDefaultRole,
              onChanged: _onDefaultRoleChanged,
            ),
            const SizedBox(height: 24),
          ],
          LogoutCard(onTap: _logout),
        ],
      ),
    );
  }
}
