import 'package:flutter/material.dart';
import 'package:frontend/features/calendar/presentation/pages/settings_screen.dart';

class CalendarShell extends StatefulWidget {
  final Widget calendarScreen;
  final List<String> roles;

  const CalendarShell({
    super.key,
    required this.calendarScreen,
    this.roles = const [],
  });

  @override
  State<CalendarShell> createState() => _CalendarShellState();
}

class _CalendarShellState extends State<CalendarShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    widget.calendarScreen,
    SettingsScreen(roles: widget.roles),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
