import 'package:flutter/material.dart';
import 'package:frontend/features/calendar/presentation/pages/doctor_calendar_screen.dart';
import 'package:frontend/features/calendar/presentation/pages/settings_screen.dart';

/// Shell screen that wraps [DoctorCalendarScreen] and [SettingsScreen]
/// inside a [BottomNavigationBar] with tabs "Calendario" and "Ajustes".
class DoctorShellScreen extends StatefulWidget {
  const DoctorShellScreen({super.key});

  @override
  State<DoctorShellScreen> createState() => _DoctorShellScreenState();
}

class _DoctorShellScreenState extends State<DoctorShellScreen> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    DoctorCalendarScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
