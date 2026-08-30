import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/domain/entities/user_profile.dart';
import 'package:frontend/features/calendar/presentation/pages/settings_screen.dart';
import 'package:frontend/features/calendar/presentation/providers/patient_appointment_realtime_provider.dart';
import 'package:frontend/theme/calendar_theme.dart';

class CalendarShellNavigation extends InheritedWidget {
  final VoidCallback onOpenSettings;

  const CalendarShellNavigation({
    super.key,
    required this.onOpenSettings,
    required super.child,
  });

  static CalendarShellNavigation? maybeOf(BuildContext context) {
    return context
            .getElementForInheritedWidgetOfExactType<CalendarShellNavigation>()
            ?.widget
        as CalendarShellNavigation?;
  }

  @override
  bool updateShouldNotify(CalendarShellNavigation oldWidget) => false;
}

class CalendarShell extends ConsumerStatefulWidget {
  final Widget calendarScreen;
  final UserProfile profile;

  final List<Widget> extraPages;
  final List<BottomNavigationBarItem> extraItems;

  const CalendarShell({
    super.key,
    required this.calendarScreen,
    required this.profile,
    this.extraPages = const [],
    this.extraItems = const [],
  }) : assert(
         extraPages.length == extraItems.length,
         'extraPages y extraItems deben tener la misma cantidad de elementos.',
       );

  @override
  ConsumerState<CalendarShell> createState() => _CalendarShellState();
}

class _CalendarShellState extends ConsumerState<CalendarShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    widget.calendarScreen,
    ...widget.extraPages,
    SettingsScreen(profile: widget.profile),
  ];

  late final List<BottomNavigationBarItem> _items = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month),
      label: 'Calendario',
    ),
    ...widget.extraItems,
    const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
  ];

  @override
  Widget build(BuildContext context) {
    ref.watch(patientAppointmentRealtimeProvider(widget.profile.id));

    return CalendarShellNavigation(
      onOpenSettings: () {
        final settingsIndex = _items.length - 1;
        if (_currentIndex != settingsIndex) {
          setState(() => _currentIndex = settingsIndex);
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: CalendarColors.navUnselected,
          items: _items,
        ),
      ),
    );
  }
}
