import 'package:flutter/material.dart';
import 'package:frontend/core/services/default_role_service.dart';
import 'package:frontend/features/admin/presentation/pages/admin_panel.dart';
import 'package:frontend/features/admin/presentation/pages/superadmin_panel.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';
import 'package:frontend/features/auth/presentation/pages/role_selection_screen.dart';
import 'package:frontend/features/calendar/presentation/pages/doctor_calendar_screen.dart';
import 'package:frontend/features/calendar/presentation/pages/patient_calendar_screen.dart';
import 'package:frontend/features/calendar/presentation/pages/secretary_calendar_screen.dart';
import 'package:frontend/features/calendar/presentation/widgets/calendar_shell.dart';
import 'package:frontend/features/search/presentation/pages/search_screen.dart';

class AuthNavigation {
  const AuthNavigation._();

  static Future<void> goAfterLogin({
    required BuildContext context,
    required UserProfile profile,
  }) async {
    final roles = profile.roles;

    if (roles.length == 1) {
      _pushReplacement(context, screenForRole(roles.first, profile));
      return;
    }

    final defaultRole = await DefaultRoleService.getDefaultRole();

    if (!context.mounted) return;

    if (defaultRole != null && roles.contains(defaultRole)) {
      _pushReplacement(context, screenForRole(defaultRole, profile));
      return;
    }

    _pushReplacement(context, RoleSelectionScreen(profile: profile));
  }

  static void goAfterRegister({
    required BuildContext context,
    required UserProfile profile,
  }) {
    final roles = profile.roles;

    if (roles.length == 1) {
      _pushReplacement(context, screenForRole(roles.first, profile));
      return;
    }

    _pushReplacement(context, RoleSelectionScreen(profile: profile));
  }

  static void goToSuperadmin(BuildContext context) {
    _pushReplacement(context, const SuperadminPanel());
  }

  static void goToRole({
    required BuildContext context,
    required String role,
    required UserProfile profile,
  }) {
    _pushReplacement(context, screenForRole(role, profile));
  }

  static Widget screenForRole(String role, UserProfile profile) {
    switch (role) {
      case 'doctor':
        return CalendarShell(
          calendarScreen: DoctorCalendarScreen(profile: profile),
          profile: profile,
        );

      case 'secretary':
        return CalendarShell(
          calendarScreen: SecretaryCalendarScreen(profile: profile),
          profile: profile,
        );

      case 'patient':
        return CalendarShell(
          calendarScreen: PatientCalendarScreen(profile: profile),
          profile: profile,
          extraPages: const [SearchScreen()],
          extraItems: const [
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          ],
        );

      case 'admin':
        if (profile.adminOf.isEmpty) {
          return RoleSelectionScreen(profile: profile);
        }

        final organization = profile.adminOf.first;

        return AdminPanel(
          clientId: organization.clientId,
          clientName: organization.clientName,
        );

      default:
        return RoleSelectionScreen(profile: profile);
    }
  }

  static void _pushReplacement(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
