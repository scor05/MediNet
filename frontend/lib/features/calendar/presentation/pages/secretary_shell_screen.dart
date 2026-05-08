import 'package:flutter/material.dart';
import 'package:frontend/features/calendar/presentation/pages/secretary_calendar_screen.dart';
import 'package:frontend/features/calendar/presentation/pages/secretary_pending_appointments_screen.dart';
import 'package:frontend/features/calendar/presentation/pages/settings_screen.dart';

/// Shell screen that wraps the secretary tabs inside a [BottomNavigationBar].
class SecretaryShellScreen extends StatefulWidget {
  final List<String> roles;

  const SecretaryShellScreen({super.key, this.roles = const []});

  @override
  State<SecretaryShellScreen> createState() => _SecretaryShellScreenState();
}

class _SecretaryShellScreenState extends State<SecretaryShellScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const SecretaryCalendarScreen(),
    const SecretaryPendingAppointmentsScreen(),
    SettingsScreen(roles: widget.roles),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'Pendientes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
