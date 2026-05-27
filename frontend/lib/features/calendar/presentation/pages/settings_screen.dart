import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/services/default_role_service.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';
import 'package:frontend/features/auth/presentation/pages/role_selection_screen.dart';
import 'package:frontend/features/auth/presentation/utils/auth_role_labels.dart';
import 'package:frontend/features/auth/presentation/utils/logout_helper.dart';
import 'package:frontend/features/calendar/data/datasources/notification_preference_remote_datasource.dart';
import 'package:frontend/features/calendar/presentation/widgets/settings/default_role_card.dart';
import 'package:frontend/features/calendar/presentation/widgets/settings/logout_card.dart';
import 'package:frontend/features/calendar/presentation/widgets/settings/settings_section_description.dart';
import 'package:frontend/features/calendar/presentation/widgets/settings/settings_section_title.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final UserProfile profile;

  const SettingsScreen({super.key, required this.profile});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _notificationDatasource = NotificationPreferenceRemoteDatasource();

  String? _defaultRole;
  bool _loadingDefaultRole = true;

  bool _loadingNotifications = true;
  bool _savingNotifications = false;
  Set<String> _selectedChannels = {};

  @override
  void initState() {
    super.initState();
    _loadDefaultRole();
    _loadNotificationPreferences();
  }

  Future<void> _loadDefaultRole() async {
    final role = await DefaultRoleService.getDefaultRole();

    if (!mounted) return;

    setState(() {
      _defaultRole = role;
      _loadingDefaultRole = false;
    });
  }

  Future<void> _loadNotificationPreferences() async {
    try {
      final channels = await _notificationDatasource.getPreferences(
        widget.profile.id,
      );

      if (!mounted) return;

      setState(() {
        _selectedChannels = channels.toSet();
        _loadingNotifications = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _loadingNotifications = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudieron cargar las preferencias.'),
        ),
      );
    }
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

  Future<void> _onNotificationChannelChanged(
    String channel,
    bool enabled,
  ) async {
    final previousChannels = Set<String>.from(_selectedChannels);

    setState(() {
      _savingNotifications = true;

      if (enabled) {
        _selectedChannels.add(channel);
      } else {
        _selectedChannels.remove(channel);
      }
    });

    try {
      await _notificationDatasource.updatePreferences(
        userId: widget.profile.id,
        channels: _selectedChannels.toList(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferencias de notificación actualizadas.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _selectedChannels = previousChannels;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudieron guardar las preferencias.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _savingNotifications = false);
      }
    }
  }

  Future<void> _logout() async {
    await logoutAndGoToWelcome(context: context, ref: ref);
  }

  void _changeRole() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RoleSelectionScreen(profile: widget.profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roles = widget.profile.roles;
    final showRoleSelector = roles.length > 1;

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
              roles: roles,
              selectedRole: _defaultRole,
              loading: _loadingDefaultRole,
              onChanged: _onDefaultRoleChanged,
            ),
            const SizedBox(height: 24),
            const SettingsSectionTitle(title: 'Cambiar de rol'),
            const SizedBox(height: 4),
            const SettingsSectionDescription(
              text: 'Cambia temporalmente el modo de uso sin cerrar sesión.',
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _changeRole,
              child: const Text('Cambiar de rol'),
            ),
            const SizedBox(height: 24),
          ],

          const SettingsSectionTitle(title: 'Notificaciones'),
          const SizedBox(height: 4),
          const SettingsSectionDescription(
            text:
                'Selecciona los canales por los que deseas recibir notificaciones.',
          ),
          const SizedBox(height: 12),

          if (_loadingNotifications)
            const Center(child: CircularProgressIndicator())
          else ...[
            SwitchListTile(
              title: const Text('WhatsApp'),
              subtitle: const Text('Recibir notificaciones por WhatsApp.'),
              value: _selectedChannels.contains('whatsapp'),
              onChanged: _savingNotifications
                  ? null
                  : (value) =>
                      _onNotificationChannelChanged('whatsapp', value),
            ),
            SwitchListTile(
              title: const Text('Email'),
              subtitle: const Text('Recibir notificaciones por correo.'),
              value: _selectedChannels.contains('email'),
              onChanged: _savingNotifications
                  ? null
                  : (value) => _onNotificationChannelChanged('email', value),
            ),
            SwitchListTile(
              title: const Text('Push'),
              subtitle: const Text('Recibir notificaciones dentro de la app.'),
              value: _selectedChannels.contains('push'),
              onChanged: _savingNotifications
                  ? null
                  : (value) => _onNotificationChannelChanged('push', value),
            ),
          ],

          const SizedBox(height: 24),
          LogoutCard(onTap: _logout),
        ],
      ),
    );
  }
}
